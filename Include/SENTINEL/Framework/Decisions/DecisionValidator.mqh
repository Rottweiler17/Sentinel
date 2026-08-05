//+------------------------------------------------------------------+
//|                                            DecisionValidator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "DecisionSnapshot.mqh"

/// @class CDecisionValidator
/// @brief Sanitizes and validates confluence scores.
class CDecisionValidator
{
public:
   static bool IsValidSnapshot(const SDecisionSnapshot &snap)
   {
      return (snap.overallScore >= 0.0 && snap.overallScore <= 100.0);
   }
};
