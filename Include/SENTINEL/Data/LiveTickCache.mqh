//+------------------------------------------------------------------+
//|                                                LiveTickCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Common/Types.mqh"
#include "../Memory/RingBuffer.mqh"

/// @class CLiveTickCache
/// @brief Fixed-capacity ring buffer tick cache storing STickData.
class CLiveTickCache
{
private:
   CRingBuffer<STickData> m_ticks;

public:
   CLiveTickCache(int capacity = SENTINEL_DEFAULT_TICK_CAPACITY)
      : m_ticks(capacity, true)
   {}

   bool AddTick(const STickData &tick)
   {
      return m_ticks.Push(tick);
   }

   bool GetTick(int index, STickData &outTick) const
   {
      return m_ticks.Get(index, outTick);
   }

   bool GetLatestTick(STickData &outTick) const
   {
      return m_ticks.Back(outTick);
   }

   int Size() const { return m_ticks.Size(); }
   void Clear() { m_ticks.Clear(); }
};
