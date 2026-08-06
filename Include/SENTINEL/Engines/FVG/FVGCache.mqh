//+------------------------------------------------------------------+
//|                                                     FVGCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "FVGSnapshot.mqh"
#include "../../Memory/RingBuffer.mqh"

/// @class CFVGCache
/// @brief Ring buffer cache storing historical FVG snapshot frames.
class CFVGCache
{
private:
   CRingBuffer<SFVGSnapshot> m_history;

public:
   CFVGCache(int capacity = 200) : m_history(capacity, true) {}

   bool AddSnapshot(const SFVGSnapshot &snap)
   {
      return m_history.Push(snap);
   }

   bool GetSnapshot(int index, SFVGSnapshot &outSnap) const
   {
      return m_history.Get(index, outSnap);
   }

   bool GetLatestSnapshot(SFVGSnapshot &outSnap) const
   {
      return m_history.Back(outSnap);
   }

   int Size() const { return m_history.Size(); }

   void Clear() { m_history.Clear(); }
};
