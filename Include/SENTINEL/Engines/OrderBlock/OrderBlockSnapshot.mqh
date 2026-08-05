//+------------------------------------------------------------------+
//|                                           OrderBlockSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "OrderBlockTypes.mqh"

#define MAX_ACTIVE_ORDERBLOCKS 50

/// @struct SOrderBlockSnapshot
/// @brief Immutable snapshot representing current active order blocks.
struct SOrderBlockSnapshot
{
   // Snapshot Versioning & Lineage Metadata
   ulong             snapshotId;
   ulong             parentId;
   ulong             sequenceNumber;

   // Block Array
   SOrderBlock       activeBlocks[MAX_ACTIVE_ORDERBLOCKS];
   int               activeBlocksCount;
   datetime          timestamp;

   /// @brief Resets the snapshot data.
   void Reset()
   {
      snapshotId        = 0;
      parentId          = 0;
      sequenceNumber    = 0;
      activeBlocksCount = 0;
      timestamp         = 0;

      for(int i = 0; i < MAX_ACTIVE_ORDERBLOCKS; i++)
      {
         activeBlocks[i].id             = 0;
         activeBlocks[i].direction      = ORDERBLOCK_BULLISH;
         activeBlocks[i].creationTime   = 0;
         activeBlocks[i].upperPrice     = 0.0;
         activeBlocks[i].lowerPrice     = 0.0;
         activeBlocks[i].midPrice       = 0.0;
         activeBlocks[i].strength       = 0.0;
         activeBlocks[i].confidence     = 0.0;
         activeBlocks[i].freshness      = 0.0;
         activeBlocks[i].retestCount    = 0;
         activeBlocks[i].isMitigated    = false;
         activeBlocks[i].lifecycleState = ORDERBLOCK_STATE_INVALIDATED;
      }
   }
};
