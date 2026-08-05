//+------------------------------------------------------------------+
//|                                             DecisionAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Features/FeatureSnapshot.mqh"
#include "DecisionTypes.mqh"
#include "DecisionConfiguration.mqh"
#include "ScoringEngine.mqh"
#include "ConfidenceEngine.mqh"
#include "ConfluenceEngine.mqh"
#include "RecommendationEngine.mqh"
#include "RuleEngine.mqh"

/// @class CDecisionAnalyzer
/// @brief Aggregates all scoring engines to compute overall assessments.
class CDecisionAnalyzer
{
public:
   static void Evaluate(const SFeatureSnapshot &features,
                        const CDecisionConfiguration &config,
                        double &overallScore,
                        double &confidence,
                        double &confluence,
                        double &trendScore,
                        double &liqScore,
                        double &volScore,
                        double &orderFlowScore,
                        double &sessionScore,
                        ENUM_GENERIC_RECOMMENDATION &recommend)
   {
      // 1. Verify basic guidelines
      if(!CRuleEngine::VerifyRules(features))
      {
         overallScore = 0.0;
         confidence   = 0.0;
         confluence   = 0.0;
         recommend    = RECOMMEND_UNFAVORABLE;
         return;
      }

      // 2. Score mapping
      CScoringEngine::CalculateScores(features, trendScore, liqScore, volScore, orderFlowScore, sessionScore, overallScore);

      // 3. Confidence mapping
      confidence = CConfidenceEngine::CalculateConfidence(features);

      // 4. Confluence mapping
      confluence = CConfluenceEngine::CalculateConfluence(trendScore, liqScore, volScore, orderFlowScore, sessionScore);

      // 5. Derive recommendations
      recommend = CRecommendationEngine::DeriveRecommendation(overallScore, confluence, config);
   }
};
