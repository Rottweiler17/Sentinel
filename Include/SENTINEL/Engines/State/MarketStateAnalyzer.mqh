//+------------------------------------------------------------------+
//|                                           MarketStateAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "MarketStateTypes.mqh"
#include "MarketStateConfiguration.mqh"

/// @class CMarketStateAnalyzer
/// @brief Performs analytical evaluation of volatility ratings and trend metrics from context snapshots.
class CMarketStateAnalyzer
{
public:
   /// @brief Analyzes current volatility tier.
   static ENUM_VOLATILITY_RATING AnalyzeVolatility(const SMarketContext &context, const CMarketStateConfiguration &config)
   {
      double curSpread = context.marketData.spread;
      if(curSpread <= 0.0) return VOLATILITY_NORMAL;

      double thresholdMultiplier = curSpread / 10.0; // Normalized spread
      if(thresholdMultiplier >= config.HighVolatilityThreshold())
         return VOLATILITY_HIGH;
      if(thresholdMultiplier <= config.LowVolatilityThreshold())
         return VOLATILITY_LOW;

      return VOLATILITY_NORMAL;
   }

   /// @brief Analyzes trend intensity score (-100.0 to +100.0).
   static double AnalyzeTrendRating(const SMarketContext &context)
   {
      ENUM_TREND_TYPE extTrend = context.structure.externalTrend;
      double strength = context.structure.trendStrength;

      if(extTrend == TREND_BULLISH) return strength;
      if(extTrend == TREND_BEARISH) return -strength;
      return 0.0;
   }
};
