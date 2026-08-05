//+------------------------------------------------------------------+
//|                                           ScoringEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Features/FeatureSnapshot.mqh"

/// @class CScoringEngine
/// @brief Resolves dynamic environment quality scores from scaled features.
class CScoringEngine
{
public:
   static void CalculateScores(const SFeatureSnapshot &features, 
                               double &outTrendScore, 
                               double &outLiqScore, 
                               double &outVolScore, 
                               double &outOrderFlowScore, 
                               double &outSessionScore,
                               double &outOverallScore)
   {
      // Simple normalized score mapping
      outTrendScore     = MathMin(MathMax(features.trendStrength.normalizedValue * 100.0, 0.0), 100.0);
      outLiqScore       = MathMin(MathMax(features.liquidityScore.normalizedValue * 100.0, 0.0), 100.0);
      outVolScore       = MathMin(MathMax(features.relativeVolume.normalizedValue * 100.0, 0.0), 100.0);
      outOrderFlowScore = MathMin(MathMax(features.buyingPressure.normalizedValue * 100.0, 0.0), 100.0);
      outSessionScore   = MathMin(MathMax(features.sessionWeight.normalizedValue * 100.0, 0.0), 100.0);

      outOverallScore   = (outTrendScore + outLiqScore + outVolScore + outOrderFlowScore + outSessionScore) / 5.0;
   }
};
