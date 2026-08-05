//+------------------------------------------------------------------+
//|                                            LiquiditySnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "LiquidityTypes.mqh"

/// @struct SLiquiditySnapshot
/// @brief Immutable snapshot object emitted when liquidity state updates with confidence and zone linkage metadata.
struct SLiquiditySnapshot
{
   // Versioning & Lineage Metadata
   ulong                snapshotId;       ///< Unique identifier for this snapshot
   ulong                parentId;         ///< Identifier of previous liquidity snapshot
   ulong                sequenceNumber;   ///< Monotonically increasing sequence number

   // Nearest Key Liquidity Levels
   SLiquidityPool       nearestBSL;       ///< Nearest Buy-Side Liquidity pool above current price
   SLiquidityPool       nearestSSL;       ///< Nearest Sell-Side Liquidity pool below current price

   // Active Structural Pools
   SLiquidityPool       latestEQH;        ///< Latest Equal Highs pool
   SLiquidityPool       latestEQL;        ///< Latest Equal Lows pool

   // Sweep Information
   SLiquiditySweep      latestSweep;      ///< Latest liquidity sweep event
   ENUM_SWEEP_TYPE      sweepDirection;   ///< Bullish, Bearish, Partial, Complete
   double               sweepStrength;    ///< Sweep impact strength (0.0 to 100.0)

   // Confidence & Source Tracking for Decision Engine
   double               overallConfidence;///< Confidence score (0.0 to 100.0%)
   string               confidenceSource; ///< Source description (e.g., "Equal Highs + External Swing")

   // Counts & Telemetry
   int                  activePoolsCount;
   int                  sweptPoolsCount;
   double               liquidityQualityScore;
   datetime             timestamp;
   ENUM_TIMEFRAMES      timeframe;

   /// @brief Resets snapshot fields.
   void Reset()
   {
      snapshotId            = 0;
      parentId              = 0;
      sequenceNumber        = 0;
      sweepDirection        = SWEEP_NONE;
      sweepStrength         = 0.0;
      overallConfidence     = 0.0;
      confidenceSource      = "";
      activePoolsCount      = 0;
      sweptPoolsCount       = 0;
      liquidityQualityScore = 0.0;
      timestamp             = 0;
      timeframe             = PERIOD_CURRENT;
   }
};
