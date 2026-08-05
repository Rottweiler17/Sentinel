//+------------------------------------------------------------------+
//|                                                SessionEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "SessionTypes.mqh"

/// @class CSessionEvents
/// @brief Constructs standardized session event payloads for EventBus publication.
class CSessionEvents
{
public:
   static SSentinelEvent CreateSessionEvent(ENUM_MARKET_SESSION newSession, datetime timeVal)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_SESSION_CHANGE;
      event.timestamp  = timeVal;
      event.timeframe  = PERIOD_CURRENT;
      event.priceValue = 0.0;
      event.entityId   = (ulong)newSession;
      event.payloadJson= StringFormat("{\"session\":%d}", (int)newSession);
      return event;
   }
};
