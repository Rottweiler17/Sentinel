//+------------------------------------------------------------------+
//|                                                   RuleEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Features/FeatureSnapshot.mqh"

/// @class CRuleEngine
/// @brief Generic check rules for decision making frameworks.
class CRuleEngine
{
public:
   /// @brief Evaluates logic filters.
   static bool VerifyRules(const SFeatureSnapshot &features)
   {
      // Example rule: fail evaluation if trend strength confidence is critically low
      if(features.trendStrength.confidence < 30.0)
         return false;

      return true;
   }
};
