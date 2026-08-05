//+------------------------------------------------------------------+
//|                                             VolumeRepository.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "VolumeSnapshot.mqh"
#include "VolumeCache.mqh"

/// @class CVolumeRepository
/// @brief Repository enabling lookup queries for past volume conditions.
class CVolumeRepository
{
private:
   CVolumeCache *m_cacheRef;

public:
   CVolumeRepository(CVolumeCache *cache = NULL) : m_cacheRef(cache) {}

   void SetCache(CVolumeCache *cache) { m_cacheRef = cache; }

   bool FindById(ulong id, SVolumeSnapshot &outSnap) const
   {
      if(m_cacheRef == NULL) return false;
      int count = m_cacheRef.Size();

      for(int i = 0; i < count; i++)
      {
         SVolumeSnapshot snap;
         if(m_cacheRef.GetSnapshot(i, snap) && snap.snapshotId == id)
         {
            outSnap = snap;
            return true;
         }
      }
      return false;
   }
};
