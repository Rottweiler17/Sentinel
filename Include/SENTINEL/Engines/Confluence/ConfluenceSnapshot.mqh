//+------------------------------------------------------------------+
//|                                         ConfluenceSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ConfluenceTypes.mqh"

/// @struct SConfluenceSnapshot
/// @brief Immutable snapshot representing aggregated confluence across all analytical engines.
struct SConfluenceSnapshot
{
   // Snapshot Versioning & Lineage Metadata
   ulong                     snapshotId;
   ulong                     parentId;
   ulong                     sequenceNumber;
   datetime                  timestamp;

   // Quantitative Confluence Metrics
   double                    overallConfluenceScore;   ///< Weighted directional confluence [-1.0 to +1.0]
   double                    alignmentScore;           ///< Accordance / agreement index [0.0 to 1.0]
   double                    conflictScore;            ///< Opposing evidence polarization index [0.0 to 1.0]
   double                    confidence;               ///< Aggregated reliability [0.0 to 1.0]
   
   int                       evidenceCount;            ///< Total active evidence factors evaluated
   int                       supportingFactors;        ///< Count of aligned supporting factors
   int                       conflictingFactors;       ///< Count of opposing conflicting factors
   
   ENUM_CONFLUENCE_BIAS      netBias;                  ///< Primary net directional bias
   ENUM_CONFLUENCE_STRENGTH  strengthCategory;         ///< Categorical strength level

   // Granular Evidence breakdown (fixed array size for fast memory layout)
   SEvidenceFactor           evidenceList[EVIDENCE_SOURCE_COUNT];

   /// @brief Resets snapshot data to zero state.
   void Reset()
   {
      snapshotId             = 0;
      parentId               = 0;
      sequenceNumber         = 0;
      timestamp              = 0;

      overallConfluenceScore = 0.0;
      alignmentScore         = 0.0;
      conflictScore          = 0.0;
      confidence             = 0.0;

      evidenceCount          = 0;
      supportingFactors      = 0;
      conflictingFactors     = 0;

      netBias                = BIAS_NEUTRAL;
      strengthCategory       = CONFLUENCE_NONE;

      for(int i = 0; i < (int)EVIDENCE_SOURCE_COUNT; i++)
      {
         evidenceList[i].Reset();
         evidenceList[i].source = (ENUM_EVIDENCE_SOURCE)i;
      }
   }
};
