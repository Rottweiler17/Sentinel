//+------------------------------------------------------------------+
//|                                                DecisionCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "DecisionSnapshot.mqh"
#include "../../Memory/RingBuffer.mqh"

/// @class CDecisionCache
/// @brief Fast $O(1)$ ring buffer cache storing historical DecisionSnapshot results.
class CDecisionCache
{
private:
   CRingBuffer<SDecisionSnapshot> m_history;

public:
   CDecisionCache(int capacity = 200) : m_history(capacity, true) {}

   bool AddSnapshot(const SDecisionSnapshot &snap)
   {
      return m_history.Push(snap);
   }

   bool GetSnapshot(int index, SDecisionSnapshot &outSnap) const
   {
      return m_history.Get(index, outSnap);
   }

   bool GetLatestSnapshot(SDecisionSnapshot &outSnap) const
   {
      return m_history.Back(outSnap);
   }

   int Size() const { return m_history.Size(); }

   void Clear() { m_history.Clear(); }
};
