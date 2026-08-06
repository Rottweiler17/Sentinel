//+------------------------------------------------------------------+
//|                                           ObjectPoolRenderer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "VisualizationTypes.mqh"
#include "ChartObjectManager.mqh"

#define MAX_OBJECT_POOL_SIZE 500

/// @class CObjectPoolRenderer
/// @brief Recycles chart graphic elements in memory pool to prevent dynamic allocation overhead.
class CObjectPoolRenderer
{
private:
   SRenderObject m_pool[MAX_OBJECT_POOL_SIZE];
   int           m_activeCount;
   long          m_chartId;

public:
   CObjectPoolRenderer() : m_activeCount(0), m_chartId(0)
   {
      ClearPool();
   }

   ~CObjectPoolRenderer()
   {
      Purge();
   }

   /// @brief Initializes chart ID.
   void Initialize(long chartId)
   {
      m_chartId = chartId;
      ClearPool();
   }

   /// @brief Clears pool state.
   void ClearPool()
   {
      m_activeCount = 0;
      for(int i = 0; i < MAX_OBJECT_POOL_SIZE; i++)
         m_pool[i].Reset();
   }

   /// @brief Acquires an object from the pool.
   int AcquireObject(ENUM_VISUALIZATION_LAYER layer, ENUM_OBJECT objType, string tag)
   {
      if(m_activeCount >= MAX_OBJECT_POOL_SIZE)
         return -1;

      int idx = m_activeCount++;
      m_pool[idx].Reset();
      m_pool[idx].layer      = layer;
      m_pool[idx].objectType = objType;
      m_pool[idx].active     = true;
      m_pool[idx].name       = CChartObjectManager::FormatObjectName(layer, idx, tag);
      return idx;
   }

   /// @brief Gets pointer to object at index.
   bool SetObjectDetails(int idx, datetime t1, double p1, datetime t2, double p2, color c, int w = 1, string text = "")
   {
      if(idx < 0 || idx >= m_activeCount)
         return false;

      m_pool[idx].time1    = t1;
      m_pool[idx].price1   = p1;
      m_pool[idx].time2    = t2;
      m_pool[idx].price2   = p2;
      m_pool[idx].objColor = c;
      m_pool[idx].width    = w;
      m_pool[idx].text     = text;
      return true;
   }

   /// @brief Flushes pooled objects onto the chart.
   void Flush()
   {
      for(int i = 0; i < m_activeCount; i++)
      {
         if(m_pool[i].active)
            CChartObjectManager::RenderObject(m_chartId, m_pool[i]);
      }
   }

   /// @brief Removes all objects.
   void Purge()
   {
      CChartObjectManager::PurgeAll(m_chartId);
      ClearPool();
   }

   /// @brief Returns active pooled object count.
   int GetActiveCount() const { return m_activeCount; }

   /// @brief Returns pool capacity.
   int GetPoolSize() const { return MAX_OBJECT_POOL_SIZE; }
};
