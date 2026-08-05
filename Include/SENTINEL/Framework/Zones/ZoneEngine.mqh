//+------------------------------------------------------------------+
//|                                                   ZoneEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/BaseEngine.mqh"
#include "../../Events/EventBus.mqh"
#include "../../Data/MarketDataSnapshot.mqh"
#include "../../Engines/Structure/StructureSnapshot.mqh"
#include "../../Engines/Liquidity/LiquiditySnapshot.mqh"
#include "ZoneSnapshot.mqh"
#include "ZoneCache.mqh"
#include "ZoneFactory.mqh"
#include "ZoneValidator.mqh"
#include "ZoneManager.mqh"
#include "ZoneLifecycleManager.mqh"
#include "ZoneStatistics.mqh"
#include "IZoneEngine.mqh"

/// @class CZoneEngine
/// @brief Master Generic Zone Framework Engine. Central foundation for every price zone concept inside SENTINEL.
class CZoneEngine : public CBaseEngine, public IZoneEngine
{
private:
   CZoneConfiguration    m_config;
   CZoneCache            m_cache;
   CZoneLifecycleManager m_lifecycleManager;
   CZoneManager          m_manager;
   CZoneStatistics       m_stats;
   SZoneSnapshot         m_currentSnapshot;

   ulong                 m_snapshotSequence;
   ulong                 m_lastSnapshotId;

public:
   CZoneEngine()
      : CBaseEngine("ZoneEngine"),
        m_snapshotSequence(0),
        m_lastSnapshotId(0)
   {
      m_manager.Init(&m_cache, &m_lifecycleManager, &m_config);
   }

   /// @brief Initializes ZoneEngine and registers event listeners on EventBus.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      m_lifecycleManager.SetEventBus(m_eventBusRef);

      if(m_eventBusRef != NULL)
      {
         m_eventBusRef.Subscribe(EVENT_MKT_TICK, this);
         m_eventBusRef.Subscribe(EVENT_MKT_SWING_FOUND, this);
      }

      CLogger::Info(m_engineName, "ZoneEngine generic framework initialized.");
      return true;
   }

   /// @brief Consumes event notifications dispatched from EventBus.
   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(!m_isEnabled) return;
   }

   /// @brief Primary zone processing pipeline consuming Market, Structure, and Liquidity snapshots.
   void ProcessZones(const SMarketDataSnapshot &marketSnap, 
                     const SStructureSnapshot &structSnap, 
                     const SLiquiditySnapshot &liqSnap)
   {
      if(!m_isEnabled || marketSnap.bid <= 0.0) return;

      // 1. Process candle updates for active zone retests/mitigations
      m_manager.UpdateZonesWithCandle(marketSnap.currentCandle);

      // 2. Create Support/Demand zone candidate from Structure Swing Low
      if(structSnap.latestSwingLow.type == SWING_TYPE_LOW)
      {
         SGenericZone supZone = CZoneFactory::CreateZone(
            ZONE_CATEGORY_SUPPORT,
            structSnap.latestSwingLow.price,
            structSnap.latestSwingLow.price - (10.0 * marketSnap.point),
            structSnap.timeframe,
            structSnap.timestamp
         );

         if(CZoneValidator::IsValidZone(supZone, m_config, marketSnap.point))
         {
            m_cache.AddActiveZone(supZone);
            m_lifecycleManager.TransitionState(supZone, ZONE_LIFECYCLE_ACTIVE);
            m_stats.RecordCreated();
         }
      }

      // 3. Create Resistance/Supply zone candidate from Structure Swing High
      if(structSnap.latestSwingHigh.type == SWING_TYPE_HIGH)
      {
         SGenericZone resZone = CZoneFactory::CreateZone(
            ZONE_CATEGORY_RESISTANCE,
            structSnap.latestSwingHigh.price + (10.0 * marketSnap.point),
            structSnap.latestSwingHigh.price,
            structSnap.timeframe,
            structSnap.timestamp
         );

         if(CZoneValidator::IsValidZone(resZone, m_config, marketSnap.point))
         {
            m_cache.AddActiveZone(resZone);
            m_lifecycleManager.TransitionState(resZone, ZONE_LIFECYCLE_ACTIVE);
            m_stats.RecordCreated();
         }
      }

      // 4. Update immutable SZoneSnapshot
      UpdateSnapshot(marketSnap);
   }

   /// @brief Registers a custom generic zone constructed by specialized zone modules.
   bool RegisterZone(SGenericZone &zone, double pointVal)
   {
      if(!CZoneValidator::IsValidZone(zone, m_config, pointVal))
         return false;

      m_cache.AddActiveZone(zone);
      m_lifecycleManager.TransitionState(zone, ZONE_LIFECYCLE_ACTIVE);
      m_stats.RecordCreated();
      return true;
   }

   /// @brief Gets pointer to current immutable SZoneSnapshot.
   const SZoneSnapshot* GetSnapshot() const { return &m_currentSnapshot; }

   CZoneCache* Cache() { return &m_cache; }

private:
   /// @brief Updates current immutable SZoneSnapshot with version tracking.
   void UpdateSnapshot(const SMarketDataSnapshot &marketSnap)
   {
      m_snapshotSequence++;
      ulong newSnapshotId = (ulong)marketSnap.time_msc + m_snapshotSequence;

      m_currentSnapshot.Reset();
      m_currentSnapshot.snapshotId          = newSnapshotId;
      m_currentSnapshot.parentId            = m_lastSnapshotId;
      m_currentSnapshot.sequenceNumber      = m_snapshotSequence;

      // Find nearest Support and Resistance relative to current price
      m_cache.FindNearestSupport(marketSnap.bid, m_currentSnapshot.nearestSupport);
      m_cache.FindNearestResistance(marketSnap.bid, m_currentSnapshot.nearestResistance);

      m_currentSnapshot.activeZonesCount    = m_cache.ActiveZonesCount();
      m_currentSnapshot.mergedZonesCount    = m_cache.MergedZonesCount();
      m_currentSnapshot.expiredZonesCount   = m_cache.ExpiredZonesCount();
      m_currentSnapshot.zoneQualityScore    = m_stats.QualityScore();
      m_currentSnapshot.timestamp           = marketSnap.time;
      m_currentSnapshot.timeframe           = marketSnap.timeframe;

      m_lastSnapshotId = newSnapshotId;
   }
};
