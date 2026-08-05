//+------------------------------------------------------------------+
//|                                               OrderFlowCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "OrderFlowSnapshot.mqh"
#include "../../Memory/RingBuffer.mqh"

/// @class COrderFlowCache
/// @brief Fast $O(1)$ ring buffer cache storing historical OrderFlow snapshots.
class COrderFlowCache
{
private:
   CRingBuffer<SOrderFlowSnapshot> m_history;

public:
   COrderFlowCache(int capacity = 200) : m_history(capacity, true) {}

   bool AddSnapshot(const SOrderFlowSnapshot &snap)
   {
      return m_history.Push(snap);
   }

   bool GetSnapshot(int index, SOrderFlowSnapshot &outSnap) const
   {
      return m_history.Get(index, outSnap);
   }

   bool GetLatestSnapshot(SOrderFlowSnapshot &outSnap) const
   {
      return m_history.Back(outSnap);
   }

   int Size() const { return m_history.Size(); }

   void Clear() { m_history.Clear(); }
};
