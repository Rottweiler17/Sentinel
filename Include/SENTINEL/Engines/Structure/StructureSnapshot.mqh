//+------------------------------------------------------------------+
//|                                            StructureSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "StructureTypes.mqh"
#include "MarketStateMachine.mqh"

/// @struct SStructureSnapshot
/// @brief Immutable market structure state snapshot consumed by future engines with versioning & state machine metadata.
struct SStructureSnapshot
{
   // Snapshot Versioning & Lineage Metadata
   ulong             snapshotId;       ///< Unique identifier for this snapshot
   ulong             parentId;         ///< Identifier of previous structure snapshot
   ulong             sequenceNumber;   ///< Monotonically increasing sequence number

   // State Machine & Trend Metrics
   ENUM_MARKET_STATE currentState;     ///< Cycle state (Accumulation, Uptrend, Pullback, Continuation, Distribution)
   ENUM_TREND_TYPE   externalTrend;
   ENUM_TREND_TYPE   internalTrend;
   double            trendStrength;

   // Key Swings
   SSwingPoint       latestSwingHigh;
   SSwingPoint       latestSwingLow;
   SSwingPoint       previousSwingHigh;
   SSwingPoint       previousSwingLow;

   // Structural Break State
   SBOSData          latestBOS;
   SCHOCHData        latestCHOCH;
   ENUM_BREAK_TYPE   lastBreakType;

   // Statistics & Quality
   double            structureQuality;
   datetime          timestamp;
   ENUM_TIMEFRAMES   timeframe;

   /// @brief Resets snapshot fields.
   void Reset()
   {
      snapshotId       = 0;
      parentId         = 0;
      sequenceNumber   = 0;
      currentState     = STATE_UNKNOWN;
      externalTrend    = TREND_UNKNOWN;
      internalTrend    = TREND_UNKNOWN;
      trendStrength    = 0.0;
      lastBreakType    = BREAK_NONE;
      structureQuality = 0.0;
      timestamp        = 0;
      timeframe        = PERIOD_CURRENT;
   }
};
