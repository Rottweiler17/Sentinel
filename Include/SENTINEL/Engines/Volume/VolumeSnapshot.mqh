//+------------------------------------------------------------------+
//|                                               VolumeSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "VolumeTypes.mqh"

/// @struct SVolumeSnapshot
/// @brief Immutable snapshot of generic volume analysis metrics.
struct SVolumeSnapshot
{
   // Snapshot Versioning & Lineage Metadata
   ulong                snapshotId;
   ulong                parentId;
   ulong                sequenceNumber;

   // Volume Metric Details
   long                 currentTickVolume;
   double               currentRealVolume;
   double               rollingAverageVolume;
   double               relativeVolume;      ///< Ratio (e.g. 1.5x average)
   ENUM_VOLUME_TREND    volumeTrend;
   ENUM_VOLUME_STATE    volumeState;

   double               sessionVolume;
   double               dailyVolume;
   double               rateOfChange;        ///< Volume percentage rate of change
   datetime             timestamp;

   /// @brief Resets the snapshot data.
   void Reset()
   {
      snapshotId           = 0;
      parentId             = 0;
      sequenceNumber       = 0;
      currentTickVolume    = 0;
      currentRealVolume    = 0.0;
      rollingAverageVolume = 0.0;
      relativeVolume       = 1.0;
      volumeTrend          = VOLUME_TREND_STABLE;
      volumeState          = VOLUME_STATE_NORMAL;
      sessionVolume        = 0.0;
      dailyVolume          = 0.0;
      rateOfChange         = 0.0;
      timestamp            = 0;
   }
};
