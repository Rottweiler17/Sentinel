//+------------------------------------------------------------------+
//|                                              StructureEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "StructureTypes.mqh"

/// @class CStructureEvents
/// @brief Helper class constructing standardized structure SSentinelEvent payloads for EventBus publication.
class CStructureEvents
{
public:
   static SSentinelEvent CreateSwingEvent(const SSwingPoint &swing)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_SWING_FOUND;
      event.timestamp  = swing.time;
      event.timeframe  = swing.timeframe;
      event.priceValue = swing.price;
      event.entityId   = swing.id;
      event.payloadJson= StringFormat("{\"type\":\"%s\",\"barIndex\":%d}", 
                                      (swing.type == SWING_TYPE_HIGH ? "HIGH" : "LOW"), swing.barIndex);
      return event;
   }

   static SSentinelEvent CreateBOSEvent(const SBOSData &bos)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_BOS;
      event.timestamp  = bos.time;
      event.timeframe  = bos.timeframe;
      event.priceValue = bos.breakPrice;
      event.entityId   = bos.id;
      event.payloadJson= StringFormat("{\"breakType\":\"%s\",\"brokenPrice\":%.5f}", 
                                      (bos.type == BREAK_BOS_BULLISH ? "BULLISH" : "BEARISH"), bos.brokenSwingPrice);
      return event;
   }

   static SSentinelEvent CreateCHOCHEvent(const SCHOCHData &choch)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_CHOCH;
      event.timestamp  = choch.time;
      event.timeframe  = choch.timeframe;
      event.priceValue = choch.breakPrice;
      event.entityId   = choch.id;
      event.payloadJson= StringFormat("{\"breakType\":\"%s\",\"brokenPrice\":%.5f}", 
                                      (choch.type == BREAK_CHOCH_BULLISH ? "BULLISH" : "BEARISH"), choch.brokenSwingPrice);
      return event;
   }
};
