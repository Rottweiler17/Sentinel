//+------------------------------------------------------------------+
//|                                                FeatureEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/BaseEngine.mqh"
#include "../../Events/EventBus.mqh"
#include "IFeatureEngine.mqh"
#include "FeatureConfiguration.mqh"
#include "FeatureCache.mqh"
#include "FeatureExtractor.mqh"
#include "FeatureStatistics.mqh"
#include "FeatureValidator.mqh"
#include "FeatureEvents.mqh"

/// @class CFeatureEngine
/// @brief Master Feature Engineering Engine. Transforms raw context data into normalized, standard format vectors.
class CFeatureEngine : public CBaseEngine, public IFeatureEngine, public IEventListener
{
private:
   CFeatureConfiguration m_config;
   CFeatureCache         m_cache;
   CFeatureStatistics    m_stats;
   SFeatureSnapshot      m_currentSnapshot;

   ulong                 m_snapshotSequence;
   ulong                 m_lastSnapshotId;

public:
   CFeatureEngine()
      : CBaseEngine("FeatureEngine"),
        m_snapshotSequence(0),
        m_lastSnapshotId(0)
   {
      m_currentSnapshot.Reset();
   }

   /// @brief Initializes FeatureEngine.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      double minNorm = config.GetDouble("features.min_normalized", -1.0);
      double maxNorm = config.GetDouble("features.max_normalized", 1.0);
      m_config.SetNormalizedRange(minNorm, maxNorm);

      if(m_eventBusRef != NULL)
      {
         m_eventBusRef.Subscribe(EVENT_MKT_TICK, this);
      }

      CLogger::Info(m_engineName, "FeatureEngine initialized successfully.");
      return true;
   }

   /// @brief EventBus subscriber logic.
   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(!m_isEnabled) return;
   }

   /// @brief Updates and normalizes features purely from the MarketContext state.
   virtual void ProcessFeatures(const SMarketContext &context) override
   {
      if(!m_isEnabled || context.marketData.bid <= 0.0) return;

      m_stats.RecordExtraction();

      // Extract and normalize features
      CFeatureExtractor::Extract(context, m_currentSnapshot, m_config);

      // Verify overall snapshot bounds
      if(CFeatureValidator::IsValidSnapshot(m_currentSnapshot))
      {
         m_snapshotSequence++;
         ulong newSnapshotId = (ulong)context.marketData.currentTick.time_msc + m_snapshotSequence;

         m_currentSnapshot.snapshotId     = newSnapshotId;
         m_currentSnapshot.parentId       = m_lastSnapshotId;
         m_currentSnapshot.sequenceNumber = m_snapshotSequence;

         m_cache.AddSnapshot(m_currentSnapshot);
         m_lastSnapshotId = newSnapshotId;

         if(m_eventBusRef != NULL)
            m_eventBusRef.Publish(CFeatureEvents::CreateVectorCreatedEvent(m_currentSnapshot));
      }
      else
      {
         m_stats.RecordConfidenceDrop();
      }
   }

   virtual const SFeatureSnapshot* GetSnapshot() const override { return &m_currentSnapshot; }
};
