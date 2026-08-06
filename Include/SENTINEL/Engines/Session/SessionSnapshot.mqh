//+------------------------------------------------------------------+
//|                                              SessionSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "SessionTypes.mqh"

/// @struct SSessionSnapshot
/// @brief Immutable representation of global session state and reference levels.
struct SSessionSnapshot
{
   // Snapshot Versioning & Lineage Metadata
   ulong                snapshotId;
   ulong                parentId;
   ulong                sequenceNumber;

   // Session Info
   ENUM_MARKET_SESSION  currentSession;
   datetime             sessionOpenTime;
   datetime             sessionCloseTime;
   long                 elapsedSeconds;
   long                 remainingSeconds;

   // Stats & Levels
   SSessionStats        stats;
   SReferenceLevels     referenceLevels;
   datetime             timestamp;

   /// @brief Resets the snapshot data.
   void Reset()
   {
      snapshotId       = 0;
      parentId         = 0;
      sequenceNumber   = 0;
      currentSession   = SESSION_MKT_UNKNOWN;
      sessionOpenTime  = 0;
      sessionCloseTime = 0;
      elapsedSeconds   = 0;
      remainingSeconds = 0;
      timestamp        = 0;
      
      // Reset Stats
      stats.high       = 0.0;
      stats.low        = 0.0;
      stats.midpoint   = 0.0;
      stats.range      = 0.0;
      stats.openPrice  = 0.0;
      stats.closePrice = 0.0;
      stats.highTime   = 0;
      stats.lowTime    = 0;

      // Reset Levels
      referenceLevels.prevDayHigh      = 0.0;
      referenceLevels.prevDayLow       = 0.0;
      referenceLevels.prevWeekHigh     = 0.0;
      referenceLevels.prevWeekLow      = 0.0;
      referenceLevels.prevMonthHigh    = 0.0;
      referenceLevels.prevMonthLow     = 0.0;
      referenceLevels.currentDayOpen   = 0.0;
      referenceLevels.currentWeekOpen  = 0.0;
      referenceLevels.currentMonthOpen = 0.0;
   }
};
