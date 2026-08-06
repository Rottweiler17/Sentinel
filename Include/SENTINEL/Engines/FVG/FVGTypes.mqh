//+------------------------------------------------------------------+
//|                                                     FVGTypes.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @enum ENUM_FVG_DIRECTION
/// @brief Direction of Fair Value Gaps.
enum ENUM_FVG_DIRECTION
{
   FVG_BULLISH = 0,
   FVG_BEARISH
};

/// @enum ENUM_FVG_LIFECYCLE
/// @brief Lifecycle tracking state for Fair Value Gaps.
enum ENUM_FVG_LIFECYCLE
{
   FVG_STATE_CREATED = 0,
   FVG_STATE_VALIDATED,
   FVG_STATE_ACTIVE,
   FVG_STATE_PARTIALLY_FILLED,
   FVG_STATE_COMPLETELY_FILLED,
   FVG_STATE_INVALIDATED,
   FVG_STATE_EXPIRED
};

/// @struct SFairValueGap
/// @brief Structure representing a detected Fair Value Gap zone.
struct SFairValueGap
{
   ulong               id;
   ENUM_FVG_DIRECTION  direction;
   
   double              upperPrice;
   double              lowerPrice;
   double              midPrice;
   double              gapSize;
   
   datetime            creationTime;
   
   double              strength;          ///< 0.0 to 100.0%
   double              confidence;        ///< 0.0 to 100.0%
   double              freshness;         ///< 0.0 to 100.0%
   double              fillPercentage;    ///< 0.0 to 100.0%
   int                 touchCount;
   ENUM_FVG_LIFECYCLE  lifecycleState;
};
