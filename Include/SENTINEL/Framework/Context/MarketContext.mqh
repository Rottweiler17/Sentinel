//+------------------------------------------------------------------+
//|                                                MarketContext.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Data/MarketDataSnapshot.mqh"
#include "../../Engines/Structure/StructureSnapshot.mqh"
#include "../../Engines/Liquidity/LiquiditySnapshot.mqh"
#include "../Zones/ZoneSnapshot.mqh"
#include "../../Engines/Session/SessionSnapshot.mqh"

/// @struct SMarketContext
/// @brief Unified, immutable snapshot representing the complete market state at a specific moment.
struct SMarketContext
{
   // Context Versioning & Lineage Metadata
   ulong                contextId;        ///< Unique identifier for this context
   ulong                parentId;         ///< Identifier of previous context
   ulong                sequenceNumber;   ///< Monotonically increasing sequence number
   datetime             timestamp;

   // Aggregated Snapshots (by value copy to guarantee immutability)
   SMarketDataSnapshot  marketData;
   SStructureSnapshot   structure;
   SLiquiditySnapshot   liquidity;
   SZoneSnapshot        zones;
   SSessionSnapshot     session;

   /// @brief Resets all aggregated snapshots to clean zero state.
   void Reset()
   {
      contextId      = 0;
      parentId       = 0;
      sequenceNumber = 0;
      timestamp      = 0;
      marketData.Reset();
      structure.Reset();
      liquidity.Reset();
      zones.Reset();
      session.Reset();
   }
};
