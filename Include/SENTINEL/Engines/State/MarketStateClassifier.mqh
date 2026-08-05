//+------------------------------------------------------------------+
//|                                         MarketStateClassifier.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "MarketStateTypes.mqh"
#include "MarketStateConfiguration.mqh"

/// @class CMarketStateClassifier
/// @brief Classifies the concrete current market environment state based on combined context analytics.
class CMarketStateClassifier
{
public:
   /// @brief Classifies environment state using context snapshots.
   static ENUM_MARKET_ENVIRONMENT_STATE ClassifyState(const SMarketContext &context, const CMarketStateConfiguration &config)
   {
      // 1. Check for liquidity sweep occurrence
      if(context.liquidity.latestSweep.sweepType != SWEEP_NONE)
      {
         datetime timeSinceSweep = context.marketData.time - context.liquidity.latestSweep.sweepTime;
         if(timeSinceSweep < 3600) // Within 1 hour
            return STATE_ENV_POST_SWEEP;
      }

      // 2. Check for ranges / accumulation / distribution
      ENUM_TREND_TYPE extTrend = context.structure.externalTrend;
      if(extTrend == TREND_NEUTRAL)
      {
         if(context.session.currentSession == SESSION_ASIAN)
            return STATE_ENV_ACCUMULATION;
         return STATE_ENV_RANGE;
      }

      // 3. Trending states
      if(extTrend == TREND_BULLISH)
      {
         if(context.structure.trendStrength >= config.TrendStrengthThreshold())
            return STATE_ENV_TRENDING_BULLISH;
         return STATE_ENV_BULLISH_CONTINUATION;
      }

      if(extTrend == TREND_BEARISH)
      {
         if(context.structure.trendStrength >= config.TrendStrengthThreshold())
            return STATE_ENV_TRENDING_BEARISH;
         return STATE_ENV_BEARISH_CONTINUATION;
      }

      // 4. Default / fallback state
      return STATE_ENV_TRANSITION;
   }
};
