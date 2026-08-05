//+------------------------------------------------------------------+
//|                                               StructureTypes.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Types.mqh"

/// @enum ENUM_TREND_TYPE
/// @brief Directional classification of market structure trend.
enum ENUM_TREND_TYPE
{
   TREND_UNKNOWN = 0,
   TREND_BULLISH,
   TREND_BEARISH,
   TREND_NEUTRAL
};

/// @enum ENUM_STRUCTURE_TYPE
/// @brief Classification between Internal (minor/sub-structure) and External (major/swings) structure.
enum ENUM_STRUCTURE_TYPE
{
   STRUCTURE_EXTERNAL = 0,  ///< Major structural swings
   STRUCTURE_INTERNAL       ///< Minor structural swings / sub-waves
};

/// @enum ENUM_BREAK_TYPE
/// @brief Types of structure break events.
enum ENUM_BREAK_TYPE
{
   BREAK_NONE = 0,
   BREAK_BOS_BULLISH,
   BREAK_BOS_BEARISH,
   BREAK_CHOCH_BULLISH,
   BREAK_CHOCH_BEARISH
};

/// @struct SBOSData
/// @brief Record of a Break of Structure event.
struct SBOSData
{
   ulong           id;
   ENUM_BREAK_TYPE type;
   datetime        time;
   double          breakPrice;
   double          brokenSwingPrice;
   ENUM_TIMEFRAMES timeframe;
   bool            isMajor;
};

/// @struct SCHOCHData
/// @brief Record of a Change of Character event.
struct SCHOCHData
{
   ulong           id;
   ENUM_BREAK_TYPE type;
   datetime        time;
   double          breakPrice;
   double          brokenSwingPrice;
   ENUM_TIMEFRAMES timeframe;
};

/// @struct STrendData
/// @brief Trend state snapshot.
struct STrendData
{
   ENUM_TREND_TYPE externalTrend;
   ENUM_TREND_TYPE internalTrend;
   double          trendStrength;  ///< Score 0.0 to 100.0
   datetime        lastTrendChange;
};

/// @struct SStructureStats
/// @brief Statistical breakdown of structure performance.
struct SStructureStats
{
   int totalSwingsDetected;
   int totalBOSDetected;
   int totalCHOCHDetected;
   int majorSwingsCount;
   int minorSwingsCount;
   double structureQualityScore;
};
