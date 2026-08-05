//+------------------------------------------------------------------+
//|                                                   ZoneEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "ZoneTypes.mqh"

/// @class CZoneEvents
/// @brief Constructs standardized zone event payloads for EventBus publication.
class CZoneEvents
{
public:
   static SSentinelEvent CreateZoneEvent(ENUM_EVENT_TYPE eventType, const SGenericZone &zone)
   {
      SSentinelEvent event;
      event.type       = eventType;
      event.timestamp  = zone.creationTime;
      event.timeframe  = zone.timeframe;
      event.priceValue = zone.midPrice;
      event.entityId   = zone.id;
      event.payloadJson= StringFormat("{\"category\":%d,\"state\":%d,\"upper\":%.5f,\"lower\":%.5f}", 
                                      zone.category, zone.lifecycleState, zone.upperPrice, zone.lowerPrice);
      return event;
   }
};
