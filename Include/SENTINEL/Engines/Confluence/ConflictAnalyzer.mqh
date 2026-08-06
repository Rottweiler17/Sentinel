//+------------------------------------------------------------------+
//|                                           ConflictAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ConfluenceTypes.mqh"
#include "ConfluenceConfiguration.mqh"

/// @class CConflictAnalyzer
/// @brief Measures opposing evidence polarization and conflict intensity.
class CConflictAnalyzer
{
public:
   /// @brief Calculates the conflict score and conflicting factor count.
   static double CalculateConflict(const SEvidenceFactor &evidenceList[],
                                   ENUM_CONFLUENCE_BIAS primaryBias,
                                   const SConfluenceConfiguration &config,
                                   int &conflictingCount)
   {
      conflictingCount = 0;
      double conflictWeightedScore = 0.0;
      double totalWeightedCapacity = 0.0;

      for(int i = 0; i < (int)EVIDENCE_SOURCE_COUNT; i++)
      {
         if(evidenceList[i].bias == BIAS_NEUTRAL)
            continue;

         double factorImpact = evidenceList[i].weight * evidenceList[i].confidence;
         totalWeightedCapacity += factorImpact;

         // Factor opposes primary net directional bias
         if(primaryBias != BIAS_NEUTRAL && evidenceList[i].bias != primaryBias)
         {
            conflictingCount++;
            conflictWeightedScore += factorImpact * MathAbs(evidenceList[i].score);
         }
      }

      if(totalWeightedCapacity <= 0.0)
         return 0.0;

      double conflictRatio = (conflictWeightedScore / totalWeightedCapacity) * config.conflictSensitivity;
      if(conflictRatio > 1.0) conflictRatio = 1.0;
      if(conflictRatio < 0.0) conflictRatio = 0.0;

      return conflictRatio;
   }
};
