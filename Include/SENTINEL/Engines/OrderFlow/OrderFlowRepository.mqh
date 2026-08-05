//+------------------------------------------------------------------+
//|                                          OrderFlowRepository.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "OrderFlowSnapshot.mqh"
#include "OrderFlowCache.mqh"

/// @class COrderFlowRepository
/// @brief Repository enabling lookup queries for past estimated order flow dynamics.
class COrderFlowRepository
{
private:
   COrderFlowCache *m_cacheRef;

public:
   COrderFlowRepository(COrderFlowCache *cache = NULL) : m_cacheRef(cache) {}

   void SetCache(COrderFlowCache *cache) { m_cacheRef = cache; }

   bool FindById(ulong id, SOrderFlowSnapshot &outSnap) const
   {
      if(m_cacheRef == NULL) return false;
      int count = m_cacheRef.Size();

      for(int i = 0; i < count; i++)
      {
         SOrderFlowSnapshot snap;
         if(m_cacheRef.GetSnapshot(i, snap) && snap.snapshotId == id)
         {
            outSnap = snap;
            return true;
         }
      }
      return false;
   }
};
