//+------------------------------------------------------------------+
//|                                         RecommendationEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "DecisionTypes.mqh"
#include "DecisionConfiguration.mqh"

/// @class CRecommendationEngine
/// @brief Derives strategy-independent market condition recommendations.
class CRecommendationEngine
{
public:
   static ENUM_GENERIC_RECOMMENDATION DeriveRecommendation(double overallScore, double confluence, const CDecisionConfiguration &config)
   {
      if(overallScore >= config.MinScoreThreshold() && confluence >= config.ConfluenceThreshold())
         return RECOMMEND_HIGH_CONFLUENCE;
      if(overallScore >= config.MinScoreThreshold())
         return RECOMMEND_FAVORABLE;
      if(overallScore < config.MinScoreThreshold() * 0.6)
         return RECOMMEND_UNFAVORABLE;
      if(confluence < config.ConfluenceThreshold() * 0.6)
         return RECOMMEND_LOW_CONFLUENCE;

      return RECOMMEND_NEUTRAL;
   }
};
