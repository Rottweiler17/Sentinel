//+------------------------------------------------------------------+
//|                                                FeatureEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "FeatureSnapshot.mqh"

/// @class CFeatureEvents
/// @brief Helper class constructing standardized feature event payloads for EventBus publication.
class CFeatureEvents
{
public:
   static SSentinelEvent CreateVectorCreatedEvent(const SFeatureSnapshot &features)
   {
      SSentinelEvent event;
      event.type       = EVENT_SYS_CONFIG_CHANGE; // System configuration/feature change categorization
      event.timestamp  = features.timestamp;
      event.timeframe  = PERIOD_CURRENT;
      event.priceValue = features.overallConfidence;
      event.entityId   = features.snapshotId;
      event.payloadJson= StringFormat("{\"vector_seq\":%d,\"confidence\":%.2f}", 
                                      features.sequenceNumber, features.overallConfidence);
      return event;
   }
};
