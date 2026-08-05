//+------------------------------------------------------------------+
//|                                                     BarCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Common/Types.mqh"
#include "../Memory/RingBuffer.mqh"

/// @class CBarCache
/// @brief Ring buffer candle cache storing SBarData for a specific timeframe.
class CBarCache
{
private:
   CRingBuffer<SBarData> m_bars;
   ENUM_TIMEFRAMES       m_timeframe;

public:
   CBarCache(ENUM_TIMEFRAMES tf = PERIOD_CURRENT, int capacity = SENTINEL_DEFAULT_BAR_CAPACITY)
      : m_bars(capacity, true), m_timeframe(tf)
   {}

   bool AddBar(const SBarData &bar)
   {
      return m_bars.Push(bar);
   }

   bool GetBar(int index, SBarData &outBar) const
   {
      return m_bars.Get(index, outBar);
   }

   bool GetCurrentBar(SBarData &outBar) const
   {
      return m_bars.Back(outBar);
   }

   bool GetPreviousBar(SBarData &outBar) const
   {
      return m_bars.Get(1, outBar);
   }

   ENUM_TIMEFRAMES Timeframe() const { return m_timeframe; }
   int Size() const { return m_bars.Size(); }
   void Clear() { m_bars.Clear(); }
};
