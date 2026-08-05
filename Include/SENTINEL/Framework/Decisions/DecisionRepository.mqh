//+------------------------------------------------------------------+
//|                                           DecisionRepository.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "DecisionSnapshot.mqh"
#include "DecisionCache.mqh"

/// @class CDecisionRepository
/// @brief Repository enabling lookup queries for past decisions.
class CDecisionRepository
{
private:
   CDecisionCache *m_cacheRef;

public:
   CDecisionRepository(CDecisionCache *cache = NULL) : m_cacheRef(cache) {}

   void SetCache(CDecisionCache *cache) { m_cacheRef = cache; }

   bool FindById(ulong id, SDecisionSnapshot &outSnap) const
   {
      if(m_cacheRef == NULL) return false;
      int count = m_cacheRef.Size();

      for(int i = 0; i < count; i++)
      {
         SDecisionSnapshot snap;
         if(m_cacheRef.GetSnapshot(i, snap) && snap.snapshotId == id)
         {
            outSnap = snap;
            return true;
         }
      }
      return false;
   }
};
