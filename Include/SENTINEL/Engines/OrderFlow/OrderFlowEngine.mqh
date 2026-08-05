//+------------------------------------------------------------------+
//|                                                 OrderFlowEngine.mqh|
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/BaseEngine.mqh"
#include "../../Events/EventBus.mqh"
#include "IOrderFlowEngine.mqh"
#include "OrderFlowConfiguration.mqh"
#include "OrderFlowCache.mqh"
#include "OrderFlowAnalyzer.mqh"
#include "OrderFlowStatistics.mqh"
#include "OrderFlowValidator.mqh"
#include "OrderFlowEvents.mqh"

/// @class COrderFlowEngine
/// @brief Master Order Flow Approximation Engine. Calculates framework-derived pressure, initiative, and participation estimates.
/// @note DISCLAIMER: Produces framework-derived estimates based on MT5 inputs. Does not claim to provide exchange level order flow.
class COrderFlowEngine : public CBaseEngine, public IOrderFlowEngine, public IEventListener
{
private:
   COrderFlowConfiguration m_config;
   COrderFlowCache         m_cache;
   COrderFlowStatistics    m_stats;
   SOrderFlowSnapshot      m_currentSnapshot;

   ulong                   m_snapshotSequence;
   ulong                   m_lastSnapshotId;

public:
   COrderFlowEngine()
      : CBaseEngine("OrderFlowEngine"),
        m_snapshotSequence(0),
        m_lastSnapshotId(0)
   {
      m_currentSnapshot.Reset();
   }

   /// @brief Initializes OrderFlowEngine.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      double aggThresh = config.GetDouble("orderflow.aggression_threshold", 1.5);
      m_config.SetAggressionThreshold(aggThresh);

      if(m_eventBusRef != NULL)
      {
         m_eventBusRef.Subscribe(EVENT_MKT_TICK, this);
      }

      CLogger::Info(m_engineName, "OrderFlowEngine initialized successfully.");
      return true;
   }

   /// @brief EventBus subscriber logic.
   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(!m_isEnabled) return;
   }

   /// @brief Primary pipeline update loop.
   virtual void ProcessOrderFlow(const SMarketContext &context) override
   {
      if(!m_isEnabled || context.marketData.bid <= 0.0) return;

      m_stats.RecordEvaluation();

      double buyPress = 50.0;
      double sellPress = 50.0;
      double bal = 1.0;
      double partScore = 0.0;
      ENUM_INITIATIVE_TYPE init = INITIATIVE_NONE;
      ENUM_ABSORPTION_STATE abs = ABSORPTION_NONE;
      double aggression = 0.0;

      // Estimate order flow dynamics
      COrderFlowAnalyzer::ProcessAnalysis(context, m_config, buyPress, sellPress, bal, partScore, init, abs, aggression);

      bool isSignificantPressureChange = (MathAbs(buyPress - m_currentSnapshot.buyingPressure) >= 5.0);
      if(isSignificantPressureChange)
      {
         if(m_eventBusRef != NULL)
            m_eventBusRef.Publish(COrderFlowEvents::CreatePressureChangedEvent(buyPress, context.marketData.time));
      }

      // Update Snapshot
      m_snapshotSequence++;
      ulong newSnapshotId = (ulong)context.marketData.currentTick.time_msc + m_snapshotSequence;

      m_currentSnapshot.snapshotId         = newSnapshotId;
      m_currentSnapshot.parentId           = m_lastSnapshotId;
      m_currentSnapshot.sequenceNumber     = m_snapshotSequence;
      m_currentSnapshot.buyingPressure     = buyPress;
      m_currentSnapshot.sellingPressure    = sellPress;
      m_currentSnapshot.pressureBalance    = bal;
      m_currentSnapshot.participationScore = partScore;
      m_currentSnapshot.initiative         = init;
      m_currentSnapshot.absorptionEstimate = abs;
      m_currentSnapshot.aggressionEstimate = aggression;
      m_currentSnapshot.volumeConfirmation = (partScore > 50.0);
      m_currentSnapshot.confidence         = 75.0; // Fixed confidence baseline for approximation
      m_currentSnapshot.timestamp          = context.timestamp;

      m_cache.AddSnapshot(m_currentSnapshot);
      m_lastSnapshotId = newSnapshotId;
   }

   virtual const SOrderFlowSnapshot* GetSnapshot() const override { return &m_currentSnapshot; }
};
