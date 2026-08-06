//+------------------------------------------------------------------+
//|                                         ICTValidationEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "ICTValidationSnapshot.mqh"

/// @class CICTValidationEvents
/// @brief Constructs EventBus event payloads for ICT Strategy Validation state shifts.
class CICTValidationEvents
{
public:
   /// @brief Creates event notification for updated ICT validation status.
   static SSentinelEvent CreateValidationUpdatedEvent(const SICTValidationSnapshot &snapshot, datetime timeVal)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_REGIME_CHANGE;
      event.timestamp  = timeVal;
      event.timeframe  = PERIOD_CURRENT;
      event.priceValue = snapshot.overallValidationScore;
      event.entityId   = snapshot.snapshotId;
      event.payloadJson= StringFormat("{\"type\":\"ICT_VALIDATION_UPDATED\",\"score\":%.3f,\"satisfied\":%d,\"missing\":%d,\"valid\":%s}",
                                      snapshot.overallValidationScore,
                                      snapshot.satisfiedCount,
                                      snapshot.missingCount,
                                      (snapshot.isSetupValid ? "true" : "false"));
      return event;
   }
};
