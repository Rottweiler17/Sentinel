//+------------------------------------------------------------------+
//|                                                    FVGEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/BaseEngine.mqh"
#include "../../Events/EventBus.mqh"
#include "IFVGEngine.mqh"
#include "FVGConfiguration.mqh"
#include "FVGCache.mqh"
#include "FVGDetector.mqh"
#include "FVGLifecycleManager.mqh"
#include "FVGRepository.mqh"
#include "FVGStatistics.mqh"
#include "FVGValidator.mqh"
#include "FVGEvents.mqh"

/// @class CFVGEngine
/// @brief Master FVG Engine. Tracks 3-candle histories, detects imbalances, and calculates fill lifecycles.
class CFVGEngine : public CBaseEngine, public IFVGEngine, public IEventListener
{
private:
   CFVGConfiguration m_config;
   CFVGCache         m_cache;
   CFVGRepository    m_repository;
   CFVGStatistics    m_stats;
   SFVGSnapshot      m_currentSnapshot;

   // Closed candle history track
   SBarData          m_barHistory[3];
   datetime          m_lastClosedTime;

   ulong             m_snapshotSequence;
   ulong             m_lastSnapshotId;

public:
   CFVGEngine()
      : CBaseEngine("FVGEngine"),
        m_lastClosedTime(0),
        m_snapshotSequence(0),
        m_lastSnapshotId(0)
   {
      m_currentSnapshot.Reset();
      for(int i = 0; i < 3; i++)
      {
         m_barHistory[i].time = 0;
         m_barHistory[i].high = 0.0;
         m_barHistory[i].low  = 0.0;
      }
   }

   /// @brief Initializes FVGEngine.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      double minSize = config.GetDouble("fvg.min_gap_size_points", 10.0);
      m_config.SetMinGapSizePoints(minSize);

      if(m_eventBusRef != NULL)
      {
         m_eventBusRef.Subscribe(EVENT_MKT_TICK, this);
      }

      CLogger::Info(m_engineName, "FVGEngine initialized successfully.");
      return true;
   }

   /// @brief EventBus subscriber handler.
   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(!m_isEnabled) return;
   }

   /// @brief Primary pipeline updates.
   virtual void ProcessFVGs(const SMarketContext &context) override
   {
      if(!m_isEnabled || context.marketData.bid <= 0.0) return;

      datetime closedTime = context.marketData.previousCandle.time;

      // 1. Detect when a new bar has just closed
      if(closedTime != m_lastClosedTime)
      {
         // Slide history
         m_barHistory[2] = m_barHistory[1];
         m_barHistory[1] = m_barHistory[0];
         m_barHistory[0] = context.marketData.previousCandle;

         m_lastClosedTime = closedTime;

         // Check if we have 3 valid consecutive candles
         if(m_barHistory[2].time > 0 && m_barHistory[1].time > 0 && m_barHistory[0].time > 0)
         {
            SFairValueGap newGap;
            if(CFVGDetector::Detect(m_barHistory[0], m_barHistory[1], m_barHistory[2], context, m_config, newGap))
            {
               if(CFVGValidator::IsValidGap(newGap))
                  m_repository.Add(newGap);
                  m_stats.RecordDetection();

                  if(m_eventBusRef != NULL)
                     m_eventBusRef.Publish(CFVGEvents::CreateCreatedEvent(newGap, context.marketData.time));
            }
         }
      }

      // 2. Update existing Gaps
      int count = m_repository.Count();
      for(int i = 0; i < count; i++)
      {
         SFairValueGap gap;
         if(m_repository.Get(i, gap))
         {
            bool wasFilled = (gap.lifecycleState == FVG_STATE_COMPLETELY_FILLED);
            CFVGLifecycleManager::UpdateLifecycle(context, m_config, gap);
            m_repository.Update(i, gap);

            if(gap.lifecycleState == FVG_STATE_COMPLETELY_FILLED && !wasFilled)
            {
               m_stats.RecordFill();
            }
         }
      }

      // 3. Assemble Snapshot
      m_snapshotSequence++;
      ulong newSnapshotId = (ulong)context.marketData.currentTick.time_msc + m_snapshotSequence;

      m_currentSnapshot.snapshotId     = newSnapshotId;
      m_currentSnapshot.parentId       = m_lastSnapshotId;
      m_currentSnapshot.sequenceNumber = m_snapshotSequence;
      m_currentSnapshot.timestamp      = context.timestamp;
      
      int activeIndex = 0;
      for(int i = 0; i < count; i++)
      {
         SFairValueGap gap;
         if(m_repository.Get(i, gap) && gap.lifecycleState != FVG_STATE_COMPLETELY_FILLED && gap.lifecycleState != FVG_STATE_EXPIRED)
         {
            if(activeIndex < MAX_ACTIVE_FVGS)
            {
               m_currentSnapshot.activeGaps[activeIndex] = gap;
               activeIndex++;
            }
         }
      }
      m_currentSnapshot.activeGapsCount = activeIndex;

      m_cache.AddSnapshot(m_currentSnapshot);
      m_lastSnapshotId = newSnapshotId;
   }

   virtual const SFVGSnapshot* GetSnapshot() const override { return &m_currentSnapshot; }
};
