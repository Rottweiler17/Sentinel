//+------------------------------------------------------------------+
//|                                                ContextEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "MarketContext.mqh"

/// @class CContextEvents
/// @brief Constructs standardized context SSentinelEvent payloads for EventBus publication.
class CContextEvents
{
public:
   static SSentinelEvent CreateCreatedEvent(const SMarketContext &context)
   {
      SSentinelEvent event;
      event.type       = EVENT_SYS_INIT;
      event.timestamp  = context.timestamp;
      event.timeframe  = context.marketData.timeframe;
      event.priceValue = context.marketData.bid;
      event.entityId   = context.contextId;
      event.payloadJson= StringFormat("{\"sequence\":%d,\"symbol\":\"%s\"}", 
                                      context.sequenceNumber, context.marketData.symbol);
      return event;
   }
};
