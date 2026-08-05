//+------------------------------------------------------------------+
//|                                                 ContextCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "MarketContext.mqh"
#include "../../Memory/RingBuffer.mqh"

/// @class CContextCache
/// @brief Static ring buffer cache storing historical SMarketContext frames for lookup & replay.
class CContextCache
{
private:
   CRingBuffer<SMarketContext> m_contexts;

public:
   CContextCache(int capacity = 500) : m_contexts(capacity, true) {}

   bool AddContext(const SMarketContext &context)
   {
      return m_contexts.Push(context);
   }

   bool GetContext(int index, SMarketContext &outContext) const
   {
      return m_contexts.Get(index, outContext);
   }

   bool GetLatestContext(SMarketContext &outContext) const
   {
      return m_contexts.Back(outContext);
   }

   int Size() const { return m_contexts.Size(); }

   void Clear() { m_contexts.Clear(); }
};
