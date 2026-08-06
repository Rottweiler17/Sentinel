//+------------------------------------------------------------------+
//|                                                   FVGEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "FVGTypes.mqh"

/// @class CFVGEvents
/// @brief Helper class constructing Fair Value Gap event payloads for EventBus.
class CFVGEvents
{
public:
   static SSentinelEvent CreateCreatedEvent(const SFairValueGap &gap, datetime timeVal)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_REGIME_CHANGE; // Map to regime category
      event.timestamp  = timeVal;
      event.timeframe  = PERIOD_CURRENT;
      event.priceValue = gap.midPrice;
      event.entityId   = gap.id;
      event.payloadJson= StringFormat("{\"fvg_id\":%d,\"dir\":%d,\"state\":%d}", 
                                      gap.id, (int)gap.direction, (int)gap.lifecycleState);
      return event;
   }
};
