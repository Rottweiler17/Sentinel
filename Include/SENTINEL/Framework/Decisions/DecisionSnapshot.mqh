//+------------------------------------------------------------------+
//|                                                DecisionSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "DecisionTypes.mqh"

/// @struct SDecisionSnapshot
/// @brief Immutable snapshot of generic evaluation score values.
struct SDecisionSnapshot
{
   // Snapshot Versioning & Lineage Metadata
   ulong                      snapshotId;
   ulong                      parentId;
   ulong                      sequenceNumber;

   // Evaluation Scores
   double                     overallScore;        ///< 0.0 to 100.0%
   double                     confidence;          ///< 0.0 to 100.0%
   double                     confluenceScore;     ///< 0.0 to 100.0%
   
   double                     trendScore;
   double                     liquidityScore;
   double                     volumeScore;
   double                     orderFlowScore;
   double                     sessionScore;

   ENUM_GENERIC_RECOMMENDATION recommendation;
   datetime                   timestamp;

   /// @brief Resets the snapshot data.
   void Reset()
   {
      snapshotId      = 0;
      parentId       = 0;
      sequenceNumber  = 0;
      overallScore    = 0.0;
      confidence      = 0.0;
      confluenceScore = 0.0;
      trendScore      = 0.0;
      liquidityScore  = 0.0;
      volumeScore     = 0.0;
      orderFlowScore  = 0.0;
      sessionScore    = 0.0;
      recommendation  = RECOMMEND_NEUTRAL;
      timestamp       = 0;
   }
};
