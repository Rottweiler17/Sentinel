//+------------------------------------------------------------------+
//|                                                DecisionEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/BaseEngine.mqh"
#include "../../Events/EventBus.mqh"
#include "IDecisionEngine.mqh"
#include "DecisionConfiguration.mqh"
#include "DecisionCache.mqh"
#include "DecisionAnalyzer.mqh"
#include "DecisionStatistics.mqh"
#include "DecisionValidator.mqh"
#include "DecisionEvents.mqh"

/// @class CDecisionEngine
/// @brief Master Decision Framework Engine. Combines standard feature vectors to produce objective confluence scores and ratings.
class CDecisionEngine : public CBaseEngine, public IDecisionEngine, public IEventListener
{
private:
   CDecisionConfiguration m_config;
   CDecisionCache         m_cache;
   CDecisionStatistics    m_stats;
   SDecisionSnapshot      m_currentSnapshot;

   ulong                  m_snapshotSequence;
   ulong                  m_lastSnapshotId;

public:
   CDecisionEngine()
      : CBaseEngine("DecisionEngine"),
        m_snapshotSequence(0),
        m_lastSnapshotId(0)
   {
      m_currentSnapshot.Reset();
   }

   /// @brief Initializes DecisionEngine.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      double confThresh = config.GetDouble("decisions.confluence_threshold", 60.0);
      double scoreThresh = config.GetDouble("decisions.score_threshold", 50.0);
      m_config.SetConfluenceThreshold(confThresh);
      m_config.SetMinScoreThreshold(scoreThresh);

      if(m_eventBusRef != NULL)
      {
         m_eventBusRef.Subscribe(EVENT_MKT_TICK, this);
      }

      CLogger::Info(m_engineName, "DecisionEngine initialized successfully.");
      return true;
   }

   /// @brief EventBus subscriber logic.
   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(!m_isEnabled) return;
   }

   /// @brief Processes feature vectors to calculate evaluations.
   virtual void ProcessDecision(const SFeatureSnapshot &features) override
   {
      if(!m_isEnabled) return;

      m_stats.RecordEvaluation();

      double overallScore    = 0.0;
      double confidence      = 0.0;
      double confluence      = 0.0;
      double trendScore      = 0.0;
      double liqScore        = 0.0;
      double volScore        = 0.0;
      double orderFlowScore  = 0.0;
      double sessionScore    = 0.0;
      ENUM_GENERIC_RECOMMENDATION recommend = RECOMMEND_NEUTRAL;

      // Evaluate logic rules, scoring and recommendations
      CDecisionAnalyzer::Evaluate(features, m_config, 
                                  overallScore, confidence, confluence, 
                                  trendScore, liqScore, volScore, orderFlowScore, sessionScore, 
                                  recommend);

      if(recommend == RECOMMEND_HIGH_CONFLUENCE || recommend == RECOMMEND_FAVORABLE)
      {
         m_stats.RecordFavorable();
      }

      // Update Snapshot
      m_snapshotSequence++;
      ulong newSnapshotId = (ulong)features.timestamp + m_snapshotSequence;

      m_currentSnapshot.snapshotId      = newSnapshotId;
      m_currentSnapshot.parentId        = m_lastSnapshotId;
      m_currentSnapshot.sequenceNumber  = m_snapshotSequence;
      m_currentSnapshot.overallScore    = overallScore;
      m_currentSnapshot.confidence      = confidence;
      m_currentSnapshot.confluenceScore = confluence;
      m_currentSnapshot.trendScore      = trendScore;
      m_currentSnapshot.liquidityScore  = liqScore;
      m_currentSnapshot.volumeScore     = volScore;
      m_currentSnapshot.orderFlowScore  = orderFlowScore;
      m_currentSnapshot.sessionScore    = sessionScore;
      m_currentSnapshot.recommendation  = recommend;
      m_currentSnapshot.timestamp       = TimeCurrent();

      if(CDecisionValidator::IsValidSnapshot(m_currentSnapshot))
      {
         m_cache.AddSnapshot(m_currentSnapshot);
         m_lastSnapshotId = newSnapshotId;

         if(m_eventBusRef != NULL)
            m_eventBusRef.Publish(CDecisionEvents::CreateDecisionUpdatedEvent(m_currentSnapshot));
      }
   }

   virtual const SDecisionSnapshot* GetSnapshot() const override { return &m_currentSnapshot; }
};
