//+------------------------------------------------------------------+
//|                                           SessionRepository.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "SessionSnapshot.mqh"
#include "SessionCache.mqh"

/// @class CSessionRepository
/// @brief Repository enabling lookup queries for past session snapshots.
class CSessionRepository
{
private:
   CSessionCache *m_cacheRef;

public:
   CSessionRepository(CSessionCache *cache = NULL) : m_cacheRef(cache) {}

   void SetCache(CSessionCache *cache) { m_cacheRef = cache; }

   bool FindById(ulong id, SSessionSnapshot &outSnap) const
   {
      if(m_cacheRef == NULL) return false;
      int count = m_cacheRef.Size();

      for(int i = 0; i < count; i++)
      {
         SSessionSnapshot snap;
         if(m_cacheRef.GetSnapshot(i, snap) && snap.snapshotId == id)
         {
            outSnap = snap;
            return true;
         }
      }
      return false;
   }
};
