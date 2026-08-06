//+------------------------------------------------------------------+
//|                                                 OrderBlockEngine.mqh|
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/BaseEngine.mqh"
#include "../../Events/EventBus.mqh"
#include "IOrderBlockEngine.mqh"
#include "OrderBlockConfiguration.mqh"
#include "OrderBlockCache.mqh"
#include "OrderBlockDetector.mqh"
#include "OrderBlockLifecycleManager.mqh"
#include "OrderBlockRepository.mqh"
#include "OrderBlockStatistics.mqh"
#include "OrderBlockValidator.mqh"
#include "OrderBlockEvents.mqh"

/// @class COrderBlockEngine
/// @brief Master Order Block Engine. Discovers, validates, and updates order block zones.
class COrderBlockEngine : public CBaseEngine
{
private:
   COrderBlockConfiguration m_config;
   COrderBlockCache         m_cache;
   COrderBlockRepository    m_repository;
   COrderBlockStatistics    m_stats;
   SOrderBlockSnapshot      m_currentSnapshot;

   ulong                    m_snapshotSequence;
   ulong                    m_lastSnapshotId;

public:
   COrderBlockEngine()
      : CBaseEngine("OrderBlockEngine"),
        m_snapshotSequence(0),
        m_lastSnapshotId(0)
   {
      m_currentSnapshot.Reset();
   }

   /// @brief Initializes OrderBlockEngine.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      double minStrength = config.GetDouble("orderblock.min_strength", 50.0);
      int retestLimit = (int)config.GetInt("orderblock.retest_limit", 3);

      m_config.SetMinStrength(minStrength);
      m_config.SetRetestLimit(retestLimit);

      if(m_eventBusRef != NULL)
      {
         m_eventBusRef.Subscribe(EVENT_MKT_TICK, (IEventListener*)GetPointer(this));
      }

      CLogger::Info(m_engineName, "OrderBlockEngine initialized successfully.");
      return true;
   }

   /// @brief EventBus subscriber logic.
   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(!m_isEnabled) return;
   }

   /// @brief Primary pipeline updates.
   virtual void ProcessOrderBlocks(const SMarketContext &context)
   {
      if(!m_isEnabled || context.marketData.bid <= 0.0) return;

      // 1. Detect new Order Blocks
      SOrderBlock newBlock;
      if(COrderBlockDetector::Detect(context, m_config, newBlock))
      {
         if(COrderBlockValidator::IsValidBlock(newBlock))
         {
            m_repository.Add(newBlock);
            m_stats.RecordDetection();

            if(m_eventBusRef != NULL)
               m_eventBusRef.Publish(COrderBlockEvents::CreateCreatedEvent(newBlock, context.marketData.time));
         }
      }

      // 2. Update existing blocks
      int count = m_repository.Count();
      for(int i = 0; i < count; i++)
      {
         SOrderBlock block;
         if(m_repository.Get(i, block))
         {
            bool wasMitigated = block.isMitigated;
            COrderBlockLifecycleManager::UpdateLifecycle(context, m_config, block);
            m_repository.Update(i, block);

            if(block.isMitigated && !wasMitigated)
            {
               m_stats.RecordMitigation();
            }
         }
      }

      // 3. Assemble Snapshot
      m_snapshotSequence++;
      ulong newSnapshotId = (ulong)context.marketData.currentTick.time_msc + m_snapshotSequence;

      m_currentSnapshot.snapshotId        = newSnapshotId;
      m_currentSnapshot.parentId          = m_lastSnapshotId;
      m_currentSnapshot.sequenceNumber    = m_snapshotSequence;
      m_currentSnapshot.timestamp         = context.timestamp;
      
      int activeIndex = 0;
      for(int i = 0; i < count; i++)
      {
         SOrderBlock block;
         if(m_repository.Get(i, block) && !block.isMitigated && block.lifecycleState != ORDERBLOCK_STATE_EXPIRED)
         {
            if(activeIndex < MAX_ACTIVE_ORDERBLOCKS)
            {
               m_currentSnapshot.activeBlocks[activeIndex] = block;
               activeIndex++;
            }
         }
      }
      m_currentSnapshot.activeBlocksCount = activeIndex;

      m_cache.AddSnapshot(m_currentSnapshot);
      m_lastSnapshotId = newSnapshotId;
   }

   virtual bool GetSnapshot(SOrderBlockSnapshot &snapshot) const
   {
      snapshot = m_currentSnapshot;
      return true;
   }

   virtual SOrderBlockSnapshot GetSnapshot() const
   {
      return m_currentSnapshot;
   }
};
