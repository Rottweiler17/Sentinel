//+------------------------------------------------------------------+
//|                                              MarketStateEvents.mqh|
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "MarketStateTypes.mqh"

/// @class CMarketStateEvents
/// @brief Constructs standardized market state SSentinelEvent payloads for EventBus publication.
class CMarketStateEvents
{
public:
   static SSentinelEvent CreateStateChangedEvent(ENUM_MARKET_ENVIRONMENT_STATE newState, datetime timeVal)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_REGIME_CHANGE;
      event.timestamp  = timeVal;
      event.timeframe  = PERIOD_CURRENT;
      event.priceValue = 0.0;
      event.entityId   = (ulong)newState;
      event.payloadJson= StringFormat("{\"state\":%d}", (int)newState);
      return event;
   }
};
