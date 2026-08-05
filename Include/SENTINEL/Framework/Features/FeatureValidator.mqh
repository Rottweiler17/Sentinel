//+------------------------------------------------------------------+
//|                                            FeatureValidator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "FeatureSnapshot.mqh"

/// @class CFeatureValidator
/// @brief Sanitizes and validates standard feature vectors.
class CFeatureValidator
{
public:
   static bool IsValidSnapshot(const SFeatureSnapshot &snap)
   {
      return (snap.overallConfidence >= 0.0 && snap.overallConfidence <= 100.0);
   }
};
