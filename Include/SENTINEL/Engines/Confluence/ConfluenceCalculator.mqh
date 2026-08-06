//+------------------------------------------------------------------+
//|                                         ConfluenceCalculator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ConfluenceTypes.mqh"
#include "ConfluenceSnapshot.mqh"
#include "ConfluenceConfiguration.mqh"
#include "AlignmentAnalyzer.mqh"
#include "ConflictAnalyzer.mqh"

/// @class CConfluenceCalculator
/// @brief Performs mathematical synthesis of evidence factors into a final ConfluenceSnapshot.
class CConfluenceCalculator
{
public:
   /// @brief Synthesizes evidence factors into complete ConfluenceSnapshot metrics.
   static void Calculate(const SEvidenceFactor &evidenceList[],
                         const SConfluenceConfiguration &config,
                         SConfluenceSnapshot &snapshot)
   {
      double bullishSum = 0.0;
      double bearishSum = 0.0;
      double totalWeightSum = 0.0;
      double totalConfidenceSum = 0.0;
      int activeFactorCount = 0;

      for(int i = 0; i < (int)EVIDENCE_SOURCE_COUNT; i++)
      {
         if(evidenceList[i].bias == BIAS_NEUTRAL)
            continue;

         activeFactorCount++;
         double impact = evidenceList[i].weight * evidenceList[i].confidence;
         totalWeightSum += impact;
         totalConfidenceSum += evidenceList[i].confidence;

         if(evidenceList[i].bias == BIAS_BULLISH)
            bullishSum += impact * MathAbs(evidenceList[i].score);
         else if(evidenceList[i].bias == BIAS_BEARISH)
            bearishSum += impact * MathAbs(evidenceList[i].score);
      }

      snapshot.evidenceCount = activeFactorCount;

      if(totalWeightSum <= 0.0 || activeFactorCount == 0)
      {
         snapshot.netBias = BIAS_NEUTRAL;
         snapshot.overallConfluenceScore = 0.0;
         snapshot.alignmentScore = 0.0;
         snapshot.conflictScore = 0.0;
         snapshot.confidence = 0.0;
         snapshot.strengthCategory = CONFLUENCE_NONE;
         return;
      }

      // Net Directional Bias & Overall Confluence Score [-1.0 to +1.0]
      double netRawScore = (bullishSum - bearishSum) / totalWeightSum;
      if(netRawScore > 1.0) netRawScore = 1.0;
      if(netRawScore < -1.0) netRawScore = -1.0;
      snapshot.overallConfluenceScore = netRawScore;

      if(netRawScore > 0.05)
         snapshot.netBias = BIAS_BULLISH;
      else if(netRawScore < -0.05)
         snapshot.netBias = BIAS_BEARISH;
      else
         snapshot.netBias = BIAS_NEUTRAL;

      // Aggregated Confidence
      snapshot.confidence = totalConfidenceSum / (double)activeFactorCount;

      // Calculate Alignment & Conflict Scores
      int supportingCount = 0;
      int conflictingCount = 0;
      snapshot.alignmentScore = CAlignmentAnalyzer::CalculateAlignment(evidenceList, snapshot.netBias, supportingCount);
      snapshot.conflictScore  = CConflictAnalyzer::CalculateConflict(evidenceList, snapshot.netBias, config, conflictingCount);
      snapshot.supportingFactors  = supportingCount;
      snapshot.conflictingFactors = conflictingCount;

      // Classify Strength Category
      double absScore = MathAbs(snapshot.overallConfluenceScore);
      if(absScore < 0.20 || snapshot.alignmentScore < 0.30)
         snapshot.strengthCategory = CONFLUENCE_NONE;
      else if(absScore < 0.45 || snapshot.alignmentScore < 0.50)
         snapshot.strengthCategory = CONFLUENCE_WEAK;
      else if(absScore < 0.70 || snapshot.alignmentScore < 0.65)
         snapshot.strengthCategory = CONFLUENCE_MODERATE;
      else if(absScore < 0.85 || snapshot.alignmentScore < 0.80)
         snapshot.strengthCategory = CONFLUENCE_STRONG;
      else
         snapshot.strengthCategory = CONFLUENCE_EXTREME;
   }
};
