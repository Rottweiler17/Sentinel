//+------------------------------------------------------------------+
//|                                            StructureSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "StructureTypes.mqh"

/// @struct SStructureSnapshot
/// @brief Immutable market structure state snapshot consumed by future engines.
struct SStructureSnapshot
{
   // Trend Metrics
   ENUM_TREND_TYPE externalTrend;
   ENUM_TREND_TYPE internalTrend;
   double          trendStrength;

   // Key Swings
   SSwingPoint     latestSwingHigh;
   SSwingPoint     latestSwingLow;
   SSwingPoint     previousSwingHigh;
   SSwingPoint     previousSwingLow;

   // Structural Break State
   SBOSData        latestBOS;
   SCHOCHData      latestCHOCH;
   ENUM_BREAK_TYPE lastBreakType;

   // Statistics & Quality
   double          structureQuality;
   datetime        timestamp;
   ENUM_TIMEFRAMES timeframe;

   /// @brief Resets snapshot fields.
   void Reset()
   {
      externalTrend    = TREND_UNKNOWN;
      internalTrend    = TREND_UNKNOWN;
      trendStrength    = 0.0;
      lastBreakType    = BREAK_NONE;
      structureQuality = 0.0;
      timestamp        = 0;
      timeframe        = PERIOD_CURRENT;
   }
};
