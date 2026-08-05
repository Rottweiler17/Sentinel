//+------------------------------------------------------------------+
//|                                         MarketStateRepository.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "MarketStateSnapshot.mqh"
#include "MarketStateCache.mqh"

/// @class CMarketStateRepository
/// @brief Repository enabling lookup queries for past market environment states.
class CMarketStateRepository
{
private:
   CMarketStateCache *m_cacheRef;

public:
   CMarketStateRepository(CMarketStateCache *cache = NULL) : m_cacheRef(cache) {}

   void SetCache(CMarketStateCache *cache) { m_cacheRef = cache; }

   bool FindById(ulong id, SMarketStateSnapshot &outSnap) const
   {
      if(m_cacheRef == NULL) return false;
      int count = m_cacheRef.Size();

      for(int i = 0; i < count; i++)
      {
         SMarketStateSnapshot snap;
         if(m_cacheRef.GetSnapshot(i, snap) && snap.snapshotId == id)
         {
            outSnap = snap;
            return true;
         }
      }
      return false;
   }
};
