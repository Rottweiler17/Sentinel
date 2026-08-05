//+------------------------------------------------------------------+
//|                                            FeatureNormalizer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "FeatureConfiguration.mqh"

/// @class CFeatureNormalizer
/// @brief Utilities scaling raw features into configured standard numerical ranges.
class CFeatureNormalizer
{
public:
   /// @brief Scales a raw value between bounds to the target range.
   static double Normalize(double rawVal, double rawMin, double rawMax, const CFeatureConfiguration &config)
   {
      if(MathAbs(rawMax - rawMin) <= 0.0000001) return config.MinNormalized();

      double normalized = (rawVal - rawMin) / (rawMax - rawMin);
      double range = config.MaxNormalized() - config.MinNormalized();
      return config.MinNormalized() + (normalized * range);
   }
};
