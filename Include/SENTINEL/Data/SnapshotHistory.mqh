//+------------------------------------------------------------------+
//|                                              SnapshotHistory.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "MarketDataSnapshot.mqh"
#include "../Engines/Structure/StructureSnapshot.mqh"
#include "../Memory/RingBuffer.mqh"

/// @class CSnapshotHistory
/// @brief Stores historical market and structure snapshot sequences for query & replay.
class CSnapshotHistory
{
private:
   CRingBuffer<SMarketDataSnapshot> m_marketSnapshots;
   CRingBuffer<SStructureSnapshot>  m_structureSnapshots;

public:
   CSnapshotHistory(int capacity = 500)
      : m_marketSnapshots(capacity, true), m_structureSnapshots(capacity, true)
   {}

   void AddMarketSnapshot(const SMarketDataSnapshot &snap)
   {
      m_marketSnapshots.Push(snap);
   }

   void AddStructureSnapshot(const SStructureSnapshot &snap)
   {
      m_structureSnapshots.Push(snap);
   }

   bool GetMarketSnapshot(int index, SMarketDataSnapshot &outSnap) const
   {
      return m_marketSnapshots.Get(index, outSnap);
   }

   bool GetStructureSnapshot(int index, SStructureSnapshot &outSnap) const
   {
      return m_structureSnapshots.Get(index, outSnap);
   }

   int MarketSnapshotCount()    const { return m_marketSnapshots.Size(); }
   int StructureSnapshotCount() const { return m_structureSnapshots.Size(); }

   void Clear()
   {
      m_marketSnapshots.Clear();
      m_structureSnapshots.Clear();
   }
};
