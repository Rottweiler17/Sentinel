//+------------------------------------------------------------------+
//|                                            FeatureCalculator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "FeatureTypes.mqh"
#include "FeatureNormalizer.mqh"

/// @class CFeatureCalculator
/// @brief Standard mathematical transformer for feature generation.
class CFeatureCalculator
{
public:
   static SStandardFeature CreateFeature(double rawVal, double rawMin, double rawMax, 
                                         double confidence, int engineId, const CFeatureConfiguration &config)
   {
      SStandardFeature f;
      f.rawValue        = rawVal;
      f.normalizedValue = CFeatureNormalizer::Normalize(rawVal, rawMin, rawMax, config);
      f.confidence      = confidence;
      f.timestamp       = TimeCurrent();
      f.sourceEngineId  = engineId;
      return f;
   }
};
