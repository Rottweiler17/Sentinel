//+------------------------------------------------------------------+
//|                                              OrderFlowEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "OrderFlowTypes.mqh"

/// @class COrderFlowEvents
/// @brief Helper class constructing standardized order flow event payloads for EventBus publication.
class COrderFlowEvents
{
public:
   static SSentinelEvent CreatePressureChangedEvent(double buyPress, datetime timeVal)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_VOLUME_PROFILE;
      event.timestamp  = timeVal;
      event.timeframe  = PERIOD_CURRENT;
      event.priceValue = buyPress;
      event.entityId   = 10; // Custom entity identifier representing pressure updates
      event.payloadJson= StringFormat("{\"buyPressure\":%.2f}", buyPress);
      return event;
   }
};
