//+------------------------------------------------------------------+
//|                                                TrendAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "StructureTypes.mqh"

/// @class CTrendAnalyzer
/// @brief Evaluates trend direction and strength based on swing sequence progression.
class CTrendAnalyzer
{
public:
   /// @brief Evaluates trend direction based on latest and previous swings.
   static ENUM_TREND_TYPE EvaluateTrend(const SSwingPoint &lastHigh, const SSwingPoint &prevHigh,
                                        const SSwingPoint &lastLow,  const SSwingPoint &prevLow)
   {
      if(lastHigh.type == SWING_TYPE_NONE || lastLow.type == SWING_TYPE_NONE)
         return TREND_UNKNOWN;

      // Higher High and Higher Low = Bullish Trend
      if(lastHigh.price > prevHigh.price && lastLow.price > prevLow.price)
         return TREND_BULLISH;

      // Lower High and Lower Low = Bearish Trend
      if(lastHigh.price < prevHigh.price && lastLow.price < prevLow.price)
         return TREND_BEARISH;

      return TREND_NEUTRAL;
   }

   /// @brief Calculates trend strength score (0.0 to 100.0).
   static double CalculateTrendStrength(ENUM_TREND_TYPE trend, double priceChangePercent)
   {
      if(trend == TREND_UNKNOWN || trend == TREND_NEUTRAL) return 0.0;
      double rawStrength = MathAbs(priceChangePercent) * 10.0;
      return (rawStrength > 100.0) ? 100.0 : rawStrength;
   }
};
