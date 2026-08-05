//+------------------------------------------------------------------+
//|                                              LiquidityEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/BaseEngine.mqh"
#include "../../Events/EventBus.mqh"
#include "../../Data/MarketDataSnapshot.mqh"
#include "../Structure/StructureSnapshot.mqh"
#include "LiquiditySnapshot.mqh"
#include "LiquidityCache.mqh"
#include "LiquidityDetector.mqh"
#include "LiquidityStatistics.mqh"
#include "LiquidityEvents.mqh"

/// @class CLiquidityEngine
/// @brief Master Institutional Liquidity Engine. Single source of truth for all liquidity pools, BSL/SSL, and sweeps.
class CLiquidityEngine : public CBaseEngine, public IEventListener
{
private:
   CLiquidityDetector   m_detector;
   CLiquidityCache      m_cache;
   CLiquidityStatistics m_stats;
   SLiquiditySnapshot   m_currentSnapshot;

   ulong                m_snapshotSequence;
   ulong                m_lastSnapshotId;

public:
   CLiquidityEngine(double tolerancePips = 3.0)
      : CBaseEngine("LiquidityEngine"),
        m_detector(tolerancePips),
        m_snapshotSequence(0),
        m_lastSnapshotId(0)
   {}

   /// @brief Initializes LiquidityEngine and subscribes to events on EventBus.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      double tolerance = config.GetDouble("liquidity.tolerance_pips", 3.0);
      // Initialize detector tolerance

      if(m_eventBusRef != NULL)
      {
         m_eventBusRef.Subscribe(EVENT_MKT_TICK, this);
         m_eventBusRef.Subscribe(EVENT_MKT_SWING_FOUND, this);
      }

      CLogger::Info(m_engineName, StringFormat("LiquidityEngine initialized with tolerance = %.1f pips.", tolerance));
      return true;
   }

   /// @brief Consumes event notifications dispatched from EventBus.
   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(!m_isEnabled) return;
   }

   /// @brief Primary liquidity calculation method consuming MarketDataSnapshot and StructureSnapshot.
   void ProcessLiquidity(const SMarketDataSnapshot &marketSnap, const SStructureSnapshot &structSnap)
   {
      if(!m_isEnabled || marketSnap.bid <= 0.0) return;

      // 1. Process Swing High / Low for BSL / SSL Pool Detection
      if(structSnap.latestSwingHigh.type == SWING_TYPE_HIGH)
      {
         SLiquidityPool bslPool;
         if(m_detector.BSL().CreateBSLFromSwing(structSnap.latestSwingHigh, bslPool))
         {
            m_cache.AddActivePool(bslPool);
            m_stats.RecordPoolDetected();

            if(m_eventBusRef != NULL)
               m_eventBusRef.Publish(CLiquidityEvents::CreatePoolEvent(bslPool));
         }
      }

      if(structSnap.latestSwingLow.type == SWING_TYPE_LOW)
      {
         SLiquidityPool sslPool;
         if(m_detector.SSL().CreateSSLFromSwing(structSnap.latestSwingLow, sslPool))
         {
            m_cache.AddActivePool(sslPool);
            m_stats.RecordPoolDetected();

            if(m_eventBusRef != NULL)
               m_eventBusRef.Publish(CLiquidityEvents::CreatePoolEvent(sslPool));
         }
      }

      // 2. Check for Equal Highs (EQH) alignment
      if(structSnap.latestSwingHigh.type == SWING_TYPE_HIGH && structSnap.previousSwingHigh.type == SWING_TYPE_HIGH)
      {
         SLiquidityPool eqhPool;
         if(m_detector.EQH().DetectEQH(structSnap.latestSwingHigh, structSnap.previousSwingHigh, marketSnap.point, eqhPool))
         {
            m_cache.AddActivePool(eqhPool);
            m_stats.RecordPoolDetected();

            if(m_eventBusRef != NULL)
               m_eventBusRef.Publish(CLiquidityEvents::CreatePoolEvent(eqhPool));
         }
      }

      // 3. Check for Equal Lows (EQL) alignment
      if(structSnap.latestSwingLow.type == SWING_TYPE_LOW && structSnap.previousSwingLow.type == SWING_TYPE_LOW)
      {
         SLiquidityPool eqlPool;
         if(m_detector.EQL().DetectEQL(structSnap.latestSwingLow, structSnap.previousSwingLow, marketSnap.point, eqlPool))
         {
            m_cache.AddActivePool(eqlPool);
            m_stats.RecordPoolDetected();

            if(m_eventBusRef != NULL)
               m_eventBusRef.Publish(CLiquidityEvents::CreatePoolEvent(eqlPool));
         }
      }

      // 4. Check for Liquidity Sweeps against active pools
      SLiquidityPool activePool;
      if(m_cache.GetLatestActivePool(activePool))
      {
         SLiquiditySweep sweep;
         if(m_detector.Sweep().DetectSweep(marketSnap.currentCandle, activePool, marketSnap.point, sweep))
         {
            m_cache.AddSweep(sweep);
            m_stats.RecordSweep();

            if(m_eventBusRef != NULL)
               m_eventBusRef.Publish(CLiquidityEvents::CreateSweepEvent(sweep));
         }
      }

      // 5. Update LiquiditySnapshot
      UpdateSnapshot(marketSnap);
   }

   /// @brief Gets pointer to current immutable LiquiditySnapshot.
   const SLiquiditySnapshot* GetSnapshot() const { return &m_currentSnapshot; }

private:
   /// @brief Updates current immutable SLiquiditySnapshot with version tracking.
   void UpdateSnapshot(const SMarketDataSnapshot &marketSnap)
   {
      m_snapshotSequence++;
      ulong newSnapshotId = (ulong)marketSnap.time_msc + m_snapshotSequence;

      m_currentSnapshot.Reset();
      m_currentSnapshot.snapshotId            = newSnapshotId;
      m_currentSnapshot.parentId              = m_lastSnapshotId;
      m_currentSnapshot.sequenceNumber        = m_snapshotSequence;

      // Find nearest BSL and SSL relative to current price
      m_cache.FindNearestBSL(marketSnap.bid, m_currentSnapshot.nearestBSL);
      m_cache.FindNearestSSL(marketSnap.bid, m_currentSnapshot.nearestSSL);

      // Latest Sweep information
      SLiquiditySweep latestSweep;
      if(m_cache.GetLatestSweep(latestSweep))
      {
         m_currentSnapshot.latestSweep    = latestSweep;
         m_currentSnapshot.sweepDirection = latestSweep.sweepType;
         m_currentSnapshot.sweepStrength  = latestSweep.sweepStrength;
      }

      m_currentSnapshot.activePoolsCount      = m_cache.ActivePoolsCount();
      m_currentSnapshot.sweptPoolsCount       = m_cache.SweepsCount();
      m_currentSnapshot.liquidityQualityScore = m_stats.GetStats().liquidityQualityScore;
      m_currentSnapshot.timestamp             = marketSnap.time;
      m_currentSnapshot.timeframe             = marketSnap.timeframe;

      m_lastSnapshotId = newSnapshotId;
   }
};
