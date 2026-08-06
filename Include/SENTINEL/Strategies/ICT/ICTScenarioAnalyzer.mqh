//+------------------------------------------------------------------+
//|                                         ICTScenarioAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ICTValidationSnapshot.mqh"

/// @class CICTScenarioAnalyzer
/// @brief Synthesizes checklist condition results into overall ICT Validation Snapshot metrics.
class CICTScenarioAnalyzer
{
public:
   /// @brief Analyzes condition array and constructs final SICTValidationSnapshot.
   static void AnalyzeScenario(const SICTConditionResult &conditions[], SICTValidationSnapshot &outSnapshot)
   {
      int satisfied = 0;
      int missing   = 0;

      double totalAchievedWeight = 0.0;
      double totalMaxCapacity    = 0.0;
      double sumConfidence       = 0.0;

      for(int i = 0; i < (int)ICT_CONDITION_COUNT; i++)
      {
         outSnapshot.conditions[i] = conditions[i];
         totalMaxCapacity += conditions[i].weight;

         if(conditions[i].satisfied)
         {
            satisfied++;
            totalAchievedWeight += conditions[i].weight * conditions[i].score;
            sumConfidence       += conditions[i].weight;
         }
         else
         {
            missing++;
         }
      }

      outSnapshot.satisfiedCount = satisfied;
      outSnapshot.missingCount   = missing;

      if(totalMaxCapacity > 0.0)
      {
         outSnapshot.overallValidationScore = totalAchievedWeight / totalMaxCapacity;
         outSnapshot.confidence             = sumConfidence / totalMaxCapacity;
      }
      else
      {
         outSnapshot.overallValidationScore = 0.0;
         outSnapshot.confidence             = 0.0;
      }

      // ICT Setup is valid if at least 5 of 8 conditions are satisfied and score >= 0.60
      outSnapshot.isSetupValid = (satisfied >= 5 && outSnapshot.overallValidationScore >= 0.60);
   }
};
