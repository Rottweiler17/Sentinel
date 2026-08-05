//+------------------------------------------------------------------+
//|                                                  FeatureSnapshot.mqh|
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "FeatureTypes.mqh"

/// @struct SFeatureSnapshot
/// @brief Immutable snapshot of all standardized numerical/categorical features.
struct SFeatureSnapshot
{
   // Snapshot Versioning & Lineage Metadata
   ulong             snapshotId;
   ulong             parentId;
   ulong             sequenceNumber;

   // Standardized Engine Features
   SStandardFeature  trendStrength;
   SStandardFeature  structureScore;
   SStandardFeature  liquidityScore;
   SStandardFeature  liquiditySweepScore;
   SStandardFeature  zoneStrength;
   SStandardFeature  zoneFreshness;
   SStandardFeature  sessionWeight;
   SStandardFeature  volumeStrength;
   SStandardFeature  relativeVolume;
   SStandardFeature  buyingPressure;
   SStandardFeature  sellingPressure;
   SStandardFeature  participationScore;
   SStandardFeature  marketStateScore;

   double            overallConfidence;
   double            reliability;
   double            dataCompleteness;
   datetime          timestamp;

   /// @brief Resets the snapshot data.
   void Reset()
   {
      snapshotId        = 0;
      parentId          = 0;
      sequenceNumber    = 0;
      overallConfidence = 0.0;
      reliability       = 0.0;
      dataCompleteness  = 0.0;
      timestamp         = 0;

      trendStrength.rawValue       = 0.0; trendStrength.normalizedValue       = 0.0; trendStrength.confidence = 0.0;
      structureScore.rawValue      = 0.0; structureScore.normalizedValue      = 0.0; structureScore.confidence = 0.0;
      liquidityScore.rawValue      = 0.0; liquidityScore.normalizedValue      = 0.0; liquidityScore.confidence = 0.0;
      liquiditySweepScore.rawValue = 0.0; liquiditySweepScore.normalizedValue = 0.0; liquiditySweepScore.confidence = 0.0;
      zoneStrength.rawValue        = 0.0; zoneStrength.normalizedValue        = 0.0; zoneStrength.confidence = 0.0;
      zoneFreshness.rawValue       = 0.0; zoneFreshness.normalizedValue       = 0.0; zoneFreshness.confidence = 0.0;
      sessionWeight.rawValue       = 0.0; sessionWeight.normalizedValue       = 0.0; sessionWeight.confidence = 0.0;
      volumeStrength.rawValue      = 0.0; volumeStrength.normalizedValue      = 0.0; volumeStrength.confidence = 0.0;
      relativeVolume.rawValue      = 0.0; relativeVolume.normalizedValue      = 0.0; relativeVolume.confidence = 0.0;
      buyingPressure.rawValue      = 0.0; buyingPressure.normalizedValue      = 0.0; buyingPressure.confidence = 0.0;
      sellingPressure.rawValue     = 0.0; sellingPressure.normalizedValue     = 0.0; sellingPressure.confidence = 0.0;
      participationScore.rawValue  = 0.0; participationScore.normalizedValue  = 0.0; participationScore.confidence = 0.0;
      marketStateScore.rawValue    = 0.0; marketStateScore.normalizedValue    = 0.0; marketStateScore.confidence = 0.0;
   }
};
