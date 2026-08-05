//+------------------------------------------------------------------+
//|                                                DecisionEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "DecisionSnapshot.mqh"

/// @class CDecisionEvents
/// @brief Helper class constructing standardized decision event payloads for EventBus publication.
class CDecisionEvents
{
public:
   static SSentinelEvent CreateDecisionUpdatedEvent(const SDecisionSnapshot &decisions)
   {
      SSentinelEvent event;
      event.type       = EVENT_TRD_DECISION_READY;
      event.timestamp  = decisions.timestamp;
      event.timeframe  = PERIOD_CURRENT;
      event.priceValue = decisions.overallScore;
      event.entityId   = (ulong)decisions.recommendation;
      event.payloadJson= StringFormat("{\"score\":%.2f,\"recommendation\":%d}", 
                                      decisions.overallScore, (int)decisions.recommendation);
      return event;
   }
};
