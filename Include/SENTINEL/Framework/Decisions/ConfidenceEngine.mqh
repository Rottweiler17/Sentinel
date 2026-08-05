//+------------------------------------------------------------------+
//|                                             ConfidenceEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Features/FeatureSnapshot.mqh"

/// @class CConfidenceEngine
/// @brief Computes confidence metrics based on feature vector values.
class CConfidenceEngine
{
public:
   static double CalculateConfidence(const SFeatureSnapshot &features)
   {
      double sumConfidence = features.trendStrength.confidence + 
                             features.liquidityScore.confidence + 
                             features.relativeVolume.confidence + 
                             features.buyingPressure.confidence + 
                             features.sessionWeight.confidence;
      return sumConfidence / 5.0;
   }
};
