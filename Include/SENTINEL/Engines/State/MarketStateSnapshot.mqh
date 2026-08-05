//+------------------------------------------------------------------+
//|                                          MarketStateSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "MarketStateTypes.mqh"

/// @struct SMarketStateSnapshot
/// @brief Immutable snapshot of evaluated market environment classification.
struct SMarketStateSnapshot
{
   // Snapshot Versioning & Lineage Metadata
   ulong                         snapshotId;
   ulong                         parentId;
   ulong                         sequenceNumber;

   // Market State Details
   ENUM_MARKET_ENVIRONMENT_STATE currentState;
   double                        confidence;        ///< Score 0.0 to 100.0%
   double                        strength;          ///< Score 0.0 to 100.0%
   ENUM_VOLATILITY_RATING        volatilityRating;
   double                        trendRating;       ///< Trend intensity metric (-100.0 bearish to +100.0 bullish)
   bool                          isTransitioning;
   datetime                      timestamp;

   /// @brief Resets the snapshot data.
   void Reset()
   {
      snapshotId       = 0;
      parentId         = 0;
      sequenceNumber   = 0;
      currentState     = STATE_ENV_UNKNOWN;
      confidence       = 0.0;
      strength         = 0.0;
      volatilityRating = VOLATILITY_NORMAL;
      trendRating      = 0.0;
      isTransitioning  = false;
      timestamp        = 0;
   }
};
