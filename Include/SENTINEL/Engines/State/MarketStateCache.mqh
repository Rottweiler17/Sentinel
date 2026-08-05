//+------------------------------------------------------------------+
//|                                              MarketStateCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "MarketStateSnapshot.mqh"
#include "../../Memory/RingBuffer.mqh"

/// @class CMarketStateCache
/// @brief Ring buffer cache storing historical MarketState snapshots for query lookup.
class CMarketStateCache
{
private:
   CRingBuffer<SMarketStateSnapshot> m_history;

public:
   CMarketStateCache(int capacity = 200) : m_history(capacity, true) {}

   bool AddSnapshot(const SMarketStateSnapshot &snap)
   {
      return m_history.Push(snap);
   }

   bool GetSnapshot(int index, SMarketStateSnapshot &outSnap) const
   {
      return m_history.Get(index, outSnap);
   }

   bool GetLatestSnapshot(SMarketStateSnapshot &outSnap) const
   {
      return m_history.Back(outSnap);
   }

   int Size() const { return m_history.Size(); }

   void Clear() { m_history.Clear(); }
};
