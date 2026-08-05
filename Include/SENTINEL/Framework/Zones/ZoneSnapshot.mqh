//+------------------------------------------------------------------+
//|                                                 ZoneSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ZoneTypes.mqh"

/// @struct SZoneSnapshot
/// @brief Immutable snapshot object emitted when zone framework updates. Consumed by downstream modules.
struct SZoneSnapshot
{
   // Versioning & Lineage Metadata
   ulong                snapshotId;       ///< Unique identifier for this snapshot
   ulong                parentId;         ///< Identifier of previous snapshot
   ulong                sequenceNumber;   ///< Monotonically increasing sequence number

   // Key Active Zones
   SGenericZone         nearestSupport;   ///< Nearest active support zone below current price
   SGenericZone         nearestResistance;///< Nearest active resistance zone above current price

   // Counts & Telemetry
   int                  activeZonesCount;
   int                  retestedZonesCount;
   int                  mergedZonesCount;
   int                  mitigatedZonesCount;
   int                  expiredZonesCount;
   double               zoneQualityScore;
   datetime             timestamp;
   ENUM_TIMEFRAMES      timeframe;

   /// @brief Resets snapshot fields.
   void Reset()
   {
      snapshotId          = 0;
      parentId            = 0;
      sequenceNumber      = 0;
      activeZonesCount    = 0;
      retestedZonesCount  = 0;
      mergedZonesCount    = 0;
      mitigatedZonesCount = 0;
      expiredZonesCount   = 0;
      zoneQualityScore    = 0.0;
      timestamp           = 0;
      timeframe           = PERIOD_CURRENT;
   }
};
