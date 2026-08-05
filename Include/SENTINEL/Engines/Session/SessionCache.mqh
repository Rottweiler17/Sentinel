//+------------------------------------------------------------------+
//|                                                 SessionCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "SessionSnapshot.mqh"
#include "../../Memory/RingBuffer.mqh"

/// @class CSessionCache
/// @brief Ring buffer cache storing historical session snapshots for query lookup.
class CSessionCache
{
private:
   CRingBuffer<SSessionSnapshot> m_history;

public:
   CSessionCache(int capacity = 100) : m_history(capacity, true) {}

   bool AddSnapshot(const SSessionSnapshot &snap)
   {
      return m_history.Push(snap);
   }

   bool GetSnapshot(int index, SSessionSnapshot &outSnap) const
   {
      return m_history.Get(index, outSnap);
   }

   bool GetLatestSnapshot(SSessionSnapshot &outSnap) const
   {
      return m_history.Back(outSnap);
   }

   int Size() const { return m_history.Size(); }

   void Clear() { m_history.Clear(); }
};
