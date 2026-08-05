//+------------------------------------------------------------------+
//|                                           FeatureRepository.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "FeatureSnapshot.mqh"
#include "FeatureCache.mqh"

/// @class CFeatureRepository
/// @brief Repository enabling lookup queries for past feature vector states.
class CFeatureRepository
{
private:
   CFeatureCache *m_cacheRef;

public:
   CFeatureRepository(CFeatureCache *cache = NULL) : m_cacheRef(cache) {}

   void SetCache(CFeatureCache *cache) { m_cacheRef = cache; }

   bool FindById(ulong id, SFeatureSnapshot &outSnap) const
   {
      if(m_cacheRef == NULL) return false;
      int count = m_cacheRef.Size();

      for(int i = 0; i < count; i++)
      {
         SFeatureSnapshot snap;
         if(m_cacheRef.GetSnapshot(i, snap) && snap.snapshotId == id)
         {
            outSnap = snap;
            return true;
         }
      }
      return false;
   }
};
