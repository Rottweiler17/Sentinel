//+------------------------------------------------------------------+
//|                                               ContextFactory.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "MarketContext.mqh"

/// @class CContextFactory
/// @brief Instantiates raw SMarketContext objects with initialized timestamps.
class CContextFactory
{
public:
   static SMarketContext CreateContext(ulong id, ulong parentId, ulong seqNum, datetime timeVal)
   {
      SMarketContext context;
      context.contextId      = id;
      context.parentId       = parentId;
      context.sequenceNumber = seqNum;
      context.timestamp      = timeVal;
      return context;
   }
};
