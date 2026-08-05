//+------------------------------------------------------------------+
//|                                                 OrderBlockCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "OrderBlockSnapshot.mqh"
#include "../../Memory/RingBuffer.mqh"

/// @class COrderBlockCache
/// @brief Fast $O(1)$ ring buffer cache storing historical OrderBlock snapshot vectors.
class COrderBlockCache
{
private:
   CRingBuffer<SOrderBlockSnapshot> m_history;

public:
   COrderBlockCache(int capacity = 200) : m_history(capacity, true) {}

   bool AddSnapshot(const SOrderBlockSnapshot &snap)
   {
      return m_history.Push(snap);
   }

   bool GetSnapshot(int index, SOrderBlockSnapshot &outSnap) const
   {
      return m_history.Get(index, outSnap);
   }

   bool GetLatestSnapshot(SOrderBlockSnapshot &outSnap) const
   {
      return m_history.Back(outSnap);
   }

   int Size() const { return m_history.Size(); }

   void Clear() { m_history.Clear(); }
};
