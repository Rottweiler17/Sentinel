//+------------------------------------------------------------------+
//|                                           ConfluenceEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "ConfluenceSnapshot.mqh"

/// @class CConfluenceEvents
/// @brief Builder class for constructing Confluence event notifications.
class CConfluenceEvents
{
public:
   /// @brief Creates an event notification for updated confluence snapshot.
   static SSentinelEvent CreateUpdatedEvent(const SConfluenceSnapshot &snapshot, datetime timeVal)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_REGIME_CHANGE; // Mapped to primary market assessment category
      event.timestamp  = timeVal;
      event.timeframe  = PERIOD_CURRENT;
      event.priceValue = snapshot.overallConfluenceScore;
      event.entityId   = snapshot.snapshotId;
      event.payloadJson= StringFormat("{\"type\":\"CONFLUENCE_UPDATED\",\"score\":%.3f,\"align\":%.3f,\"conflict\":%.3f,\"bias\":%d}",
                                      snapshot.overallConfluenceScore,
                                      snapshot.alignmentScore,
                                      snapshot.conflictScore,
                                      (int)snapshot.netBias);
      return event;
   }

   /// @brief Creates an event notification for significant alignment shifts.
   static SSentinelEvent CreateAlignmentChangedEvent(const SConfluenceSnapshot &snapshot, datetime timeVal)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_REGIME_CHANGE;
      event.timestamp  = timeVal;
      event.timeframe  = PERIOD_CURRENT;
      event.priceValue = snapshot.alignmentScore;
      event.entityId   = snapshot.snapshotId;
      event.payloadJson= StringFormat("{\"type\":\"ALIGNMENT_CHANGED\",\"align\":%.3f,\"strength\":%d}",
                                      snapshot.alignmentScore,
                                      (int)snapshot.strengthCategory);
      return event;
   }

   /// @brief Creates an event notification when conflict exceeds threshold.
   static SSentinelEvent CreateConflictChangedEvent(const SConfluenceSnapshot &snapshot, datetime timeVal)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_REGIME_CHANGE;
      event.timestamp  = timeVal;
      event.timeframe  = PERIOD_CURRENT;
      event.priceValue = snapshot.conflictScore;
      event.entityId   = snapshot.snapshotId;
      event.payloadJson= StringFormat("{\"type\":\"CONFLICT_CHANGED\",\"conflict\":%.3f,\"conflicting_count\":%d}",
                                      snapshot.conflictScore,
                                      snapshot.conflictingFactors);
      return event;
   }
};
