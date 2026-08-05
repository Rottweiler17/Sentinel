//+------------------------------------------------------------------+
//|                                              MarketStateEngine.mqh|
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/BaseEngine.mqh"
#include "../../Events/EventBus.mqh"
#include "IMarketStateEngine.mqh"
#include "MarketStateConfiguration.mqh"
#include "MarketStateCache.mqh"
#include "MarketStateAnalyzer.mqh"
#include "MarketStateClassifier.mqh"
#include "MarketStateStatistics.mqh"
#include "MarketStateEvents.mqh"

/// @class CMarketStateEngine
/// @brief Master Market State Classification Engine. Evaluates structural trend, spreads, and sweeps to classify environment states.
class CMarketStateEngine : public CBaseEngine, public IMarketStateEngine, public IEventListener
{
private:
   CMarketStateConfiguration  m_config;
   CMarketStateCache          m_cache;
   CMarketStateStatistics     m_stats;
   SMarketStateSnapshot       m_currentSnapshot;

   ulong                      m_snapshotSequence;
   ulong                      m_lastSnapshotId;

public:
   CMarketStateEngine()
      : CBaseEngine("MarketStateEngine"),
        m_snapshotSequence(0),
        m_lastSnapshotId(0)
   {
      m_currentSnapshot.Reset();
   }

   /// @brief Initializes MarketStateEngine.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      if(m_eventBusRef != NULL)
      {
         m_eventBusRef.Subscribe(EVENT_MKT_TICK, this);
      }

      CLogger::Info(m_engineName, "MarketStateEngine initialized.");
      return true;
   }

   /// @brief EventBus listener.
   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(!m_isEnabled) return;
   }

   /// @brief Processes state updates purely from Context snapshots.
   virtual void ProcessState(const SMarketContext &context) override
   {
      if(!m_isEnabled || context.marketData.bid <= 0.0) return;

      m_stats.RecordAnalysis();

      // 1. Analyze and classify current state
      ENUM_MARKET_ENVIRONMENT_STATE newState = CMarketStateClassifier::ClassifyState(context, m_config);
      ENUM_VOLATILITY_RATING volRating = CMarketStateAnalyzer::AnalyzeVolatility(context, m_config);
      double trendInt = CMarketStateAnalyzer::AnalyzeTrendRating(context);

      bool isTransition = (newState != m_currentSnapshot.currentState);
      if(isTransition)
      {
         m_stats.RecordTransition();

         if(m_eventBusRef != NULL)
            m_eventBusRef.Publish(CMarketStateEvents::CreateStateChangedEvent(newState, context.marketData.time));
      }

      // 2. Update snapshot
      m_snapshotSequence++;
      ulong newSnapshotId = (ulong)context.marketData.currentTick.time_msc + m_snapshotSequence;

      m_currentSnapshot.snapshotId       = newSnapshotId;
      m_currentSnapshot.parentId         = m_lastSnapshotId;
      m_currentSnapshot.sequenceNumber   = m_snapshotSequence;
      m_currentSnapshot.currentState     = newState;
      m_currentSnapshot.volatilityRating = volRating;
      m_currentSnapshot.trendRating      = trendInt;
      m_currentSnapshot.isTransitioning  = isTransition;
      m_currentSnapshot.confidence       = 85.0; // Normalized confidence level
      m_currentSnapshot.strength         = MathAbs(trendInt);
      m_currentSnapshot.timestamp        = context.timestamp;

      m_cache.AddSnapshot(m_currentSnapshot);
      m_lastSnapshotId = newSnapshotId;
   }

   virtual const SMarketStateSnapshot* GetSnapshot() const override { return &m_currentSnapshot; }
};
