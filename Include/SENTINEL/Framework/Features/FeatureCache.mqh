//+------------------------------------------------------------------+
//|                                                 FeatureCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "FeatureSnapshot.mqh"
#include "../../Memory/RingBuffer.mqh"

/// @class CFeatureCache
/// @brief Fast $O(1)$ ring buffer cache storing historical FeatureSnapshot vectors.
class CFeatureCache
{
private:
   CRingBuffer<SFeatureSnapshot> m_history;

public:
   CFeatureCache(int capacity = 200) : m_history(capacity, true) {}

   bool AddSnapshot(const SFeatureSnapshot &snap)
   {
      return m_history.Push(snap);
   }

   bool GetSnapshot(int index, SFeatureSnapshot &outSnap) const
   {
      return m_history.Get(index, outSnap);
   }

   bool GetLatestSnapshot(SFeatureSnapshot &outSnap) const
   {
      return m_history.Back(outSnap);
   }

   int Size() const { return m_history.Size(); }

   void Clear() { m_history.Clear(); }
};
