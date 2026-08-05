//+------------------------------------------------------------------+
//|                                                 OrderBlockEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "OrderBlockTypes.mqh"

/// @class COrderBlockEvents
/// @brief Constructs standardized order block event payloads for EventBus publication.
class COrderBlockEvents
{
public:
   static SSentinelEvent CreateCreatedEvent(const SOrderBlock &block, datetime timeVal)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_REGIME_CHANGE; // Map to regime category
      event.timestamp  = timeVal;
      event.timeframe  = PERIOD_CURRENT;
      event.priceValue = block.midPrice;
      event.entityId   = block.id;
      event.payloadJson= StringFormat("{\"ob_id\":%d,\"dir\":%d,\"state\":%d}", 
                                      block.id, (int)block.direction, (int)block.lifecycleState);
      return event;
   }
};
