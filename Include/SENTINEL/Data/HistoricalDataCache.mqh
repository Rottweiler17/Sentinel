//+------------------------------------------------------------------+
//|                                          HistoricalDataCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "BarCache.mqh"
#include <Arrays/ArrayObj.mqh>

/// @class CHistoricalDataCache
/// @brief Multi-timeframe bar cache manager storing CBarCache instances per timeframe.
class CHistoricalDataCache
{
private:
   CBarCache *m_caches[];

public:
   CHistoricalDataCache()
   {
      ArrayResize(m_caches, 0);
   }

   ~CHistoricalDataCache()
   {
      int total = ArraySize(m_caches);
      for(int i = 0; i < total; i++)
      {
         SAFE_DELETE(m_caches[i]);
      }
      ArrayFree(m_caches);
   }

   /// @brief Gets or creates a CBarCache for a specified timeframe.
   CBarCache* GetCache(ENUM_TIMEFRAMES tf)
   {
      int total = ArraySize(m_caches);
      for(int i = 0; i < total; i++)
      {
         if(m_caches[i] != NULL && m_caches[i].Timeframe() == tf)
            return m_caches[i];
      }

      // Create new cache for timeframe
      CBarCache *newCache = new CBarCache(tf, SENTINEL_DEFAULT_BAR_CAPACITY);
      ArrayResize(m_caches, total + 1);
      m_caches[total] = newCache;
      return newCache;
   }
};
