//+------------------------------------------------------------------+
//|                                               LiquidityTypes.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Types.mqh"

/// @enum ENUM_LIQUIDITY_TYPE
/// @brief Classification of institutional liquidity pools.
enum ENUM_LIQUIDITY_TYPE
{
   LIQUIDITY_TYPE_NONE = 0,
   LIQUIDITY_TYPE_EQUAL_HIGHS,         ///< Equal Highs (EQH) resting buy-side liquidity
   LIQUIDITY_TYPE_EQUAL_LOWS,          ///< Equal Lows (EQL) resting sell-side liquidity
   LIQUIDITY_TYPE_SWING_HIGH,          ///< Major/Minor Swing High liquidity
   LIQUIDITY_TYPE_SWING_LOW,           ///< Major/Minor Swing Low liquidity
   LIQUIDITY_TYPE_BUYSIDE,             ///< General Buy-Side Liquidity (BSL)
   LIQUIDITY_TYPE_SELLSIDE,            ///< General Sell-Side Liquidity (SSL)
   LIQUIDITY_TYPE_CLUSTERED,           ///< Dense price cluster liquidity
   LIQUIDITY_TYPE_RESTING,             ///< Resting stop-loss liquidity pool
   LIQUIDITY_TYPE_INTERNAL,            ///< Internal sub-structure liquidity
   LIQUIDITY_TYPE_EXTERNAL,            ///< External macro-structure liquidity
   LIQUIDITY_TYPE_SESSION              ///< Asian, London, or NY session high/low liquidity
};

/// @enum ENUM_LIQUIDITY_STRENGTH
/// @brief Institutional strength classification of a liquidity pool.
enum ENUM_LIQUIDITY_STRENGTH
{
   LIQUIDITY_STRENGTH_WEAK = 0,
   LIQUIDITY_STRENGTH_NORMAL,
   LIQUIDITY_STRENGTH_STRONG,
   LIQUIDITY_STRENGTH_EXTREME,
   LIQUIDITY_STRENGTH_INSTITUTIONAL
};

/// @enum ENUM_SWEEP_TYPE
/// @brief Classification of liquidity sweep/purge events.
enum ENUM_SWEEP_TYPE
{
   SWEEP_NONE = 0,
   SWEEP_BULLISH,     ///< Sell-side liquidity swept by low wick, price rejects upward
   SWEEP_BEARISH,     ///< Buy-side liquidity swept by high wick, price rejects downward
   SWEEP_PARTIAL,     ///< Partial liquidity penetration
   SWEEP_COMPLETE,    ///< Complete liquidity pool consumption
   SWEEP_FALSE        ///< False breakout without rejection
};

/// @struct SLiquidityPool
/// @brief Structural data container for a single liquidity pool or zone.
struct SLiquidityPool
{
   ulong                   id;
   ENUM_LIQUIDITY_TYPE     type;
   ENUM_LIQUIDITY_STRENGTH strength;
   ENUM_TIMEFRAMES         timeframe;
   double                  priceLevel;
   double                  upperBound;
   double                  lowerBound;
   int                     touchCount;       ///< Number of times price touched level
   double                  estimatedVolume;
   datetime                creationTime;
   datetime                lastTouchTime;
   bool                    isConsumed;
   bool                    isSwept;
   datetime                consumptionTime;
};

/// @struct SLiquiditySweep
/// @brief Record of a liquidity sweep/purge event.
struct SLiquiditySweep
{
   ulong                id;
   ulong                poolId;
   ENUM_SWEEP_TYPE      sweepType;
   ENUM_LIQUIDITY_TYPE  liquidityType;
   double               sweepPrice;
   double               penetrationDepth;
   double               sweepStrength;     ///< Score 0.0 to 100.0
   datetime             sweepTime;
   ENUM_TIMEFRAMES      timeframe;
};

/// @struct SLiquidityStats
/// @brief Telemetry metrics for liquidity engine operations.
struct SLiquidityStats
{
   int totalPoolsDetected;
   int totalSweepsDetected;
   int activePoolsCount;
   int consumedPoolsCount;
   double liquidityQualityScore;
};
