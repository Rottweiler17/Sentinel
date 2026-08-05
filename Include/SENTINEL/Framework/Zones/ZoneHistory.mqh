//+------------------------------------------------------------------+
//|                                                  ZoneHistory.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ZoneSnapshot.mqh"
#include "../../Memory/RingBuffer.mqh"

/// @class CZoneHistory
/// @brief Ring buffer history container storing historical SZoneSnapshot sequences for replay & backtesting.
class CZoneHistory
{
private:
   CRingBuffer<SZoneSnapshot> m_snapshots;

public:
   CZoneHistory(int capacity = 500) : m_snapshots(capacity, true) {}

   void AddSnapshot(const SZoneSnapshot &snap)
   {
      m_snapshots.Push(snap);
   }

   bool GetSnapshot(int index, SZoneSnapshot &outSnap) const
   {
      return m_snapshots.Get(index, outSnap);
   }

   int Count() const { return m_snapshots.Size(); }

   void Clear() { m_snapshots.Clear(); }
};
