//+------------------------------------------------------------------+
//|                                                     FVGSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "FVGTypes.mqh"

#define MAX_ACTIVE_FVGS 50

/// @struct SFVGSnapshot
/// @brief Immutable snapshot representing current active Fair Value Gaps.
struct SFVGSnapshot
{
   // Snapshot Versioning & Lineage Metadata
   ulong             snapshotId;
   ulong             parentId;
   ulong             sequenceNumber;

   // Gap Array
   SFairValueGap     activeGaps[MAX_ACTIVE_FVGS];
   int               activeGapsCount;
   datetime          timestamp;

   /// @brief Resets the snapshot data.
   void Reset()
   {
      snapshotId      = 0;
      parentId       = 0;
      sequenceNumber  = 0;
      activeGapsCount = 0;
      timestamp       = 0;

      for(int i = 0; i < MAX_ACTIVE_FVGS; i++)
      {
         activeGaps[i].id             = 0;
         activeGaps[i].direction      = FVG_BULLISH;
         activeGaps[i].upperPrice     = 0.0;
         activeGaps[i].lowerPrice     = 0.0;
         activeGaps[i].midPrice       = 0.0;
         activeGaps[i].gapSize        = 0.0;
         activeGaps[i].creationTime   = 0;
         activeGaps[i].strength       = 0.0;
         activeGaps[i].confidence     = 0.0;
         activeGaps[i].freshness      = 0.0;
         activeGaps[i].fillPercentage  = 0.0;
         activeGaps[i].touchCount     = 0;
         activeGaps[i].lifecycleState = FVG_STATE_INVALIDATED;
      }
   }
};
