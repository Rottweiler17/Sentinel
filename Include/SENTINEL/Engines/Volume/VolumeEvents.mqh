//+------------------------------------------------------------------+
//|                                                 VolumeEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "VolumeTypes.mqh"

/// @class CVolumeEvents
/// @brief Helper class constructing standardized volume event payloads for EventBus publication.
class CVolumeEvents
{
public:
   static SSentinelEvent CreateVolumeEvent(ENUM_VOLUME_STATE state, double volume, datetime timeVal)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_VOLUME_PROFILE;
      event.timestamp  = timeVal;
      event.timeframe  = PERIOD_CURRENT;
      event.priceValue = volume;
      event.entityId   = (ulong)state;
      event.payloadJson= StringFormat("{\"state\":%d,\"volume\":%.2f}", (int)state, volume);
      return event;
   }
};
