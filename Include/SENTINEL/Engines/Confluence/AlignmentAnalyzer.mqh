//+------------------------------------------------------------------+
//|                                          AlignmentAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ConfluenceTypes.mqh"
#include "ConfluenceConfiguration.mqh"

/// @class CAlignmentAnalyzer
/// @brief Measures directional agreement and accordance between active evidence sources.
class CAlignmentAnalyzer
{
public:
   /// @brief Calculates the alignment score and supporting factor count.
   static double CalculateAlignment(const SEvidenceFactor &evidenceList[],
                                    ENUM_CONFLUENCE_BIAS primaryBias,
                                    int &supportingCount)
   {
      supportingCount = 0;
      double alignedWeightedScore = 0.0;
      double totalWeightedCapacity = 0.0;

      for(int i = 0; i < (int)EVIDENCE_SOURCE_COUNT; i++)
      {
         if(evidenceList[i].bias == BIAS_NEUTRAL)
            continue;

         double factorImpact = evidenceList[i].weight * evidenceList[i].confidence;
         totalWeightedCapacity += factorImpact;

         if(evidenceList[i].bias == primaryBias)
         {
            supportingCount++;
            alignedWeightedScore += factorImpact * MathAbs(evidenceList[i].score);
         }
      }

      if(totalWeightedCapacity <= 0.0)
         return 0.0;

      double alignmentRatio = alignedWeightedScore / totalWeightedCapacity;
      if(alignmentRatio > 1.0) alignmentRatio = 1.0;
      if(alignmentRatio < 0.0) alignmentRatio = 0.0;

      return alignmentRatio;
   }
};
