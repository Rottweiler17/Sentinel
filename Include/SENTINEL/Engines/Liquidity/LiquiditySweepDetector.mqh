//+------------------------------------------------------------------+
//|                                        LiquiditySweepDetector.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "LiquidityTypes.mqh"
#include "LiquidityValidator.mqh"

/// @class CLiquiditySweepDetector
/// @brief Detects Bullish, Bearish, Partial, Complete, and False liquidity sweep events.
class CLiquiditySweepDetector
{
private:
   ulong m_nextSweepId;

public:
   CLiquiditySweepDetector() : m_nextSweepId(1) {}

   /// @brief Evaluates current bar for a liquidity sweep against target liquidity pool.
   bool DetectSweep(const SBarData &currentBar, const SLiquidityPool &pool, double pointVal, SLiquiditySweep &outSweep)
   {
      if(!CLiquidityValidator::IsValidPool(pool) || pool.isConsumed)
         return false;

      // 1. Bearish Sweep (Buy-Side Liquidity / EQH / Swing High swept by high wick)
      if(pool.type == LIQUIDITY_TYPE_EQUAL_HIGHS || pool.type == LIQUIDITY_TYPE_BUYSIDE || pool.type == LIQUIDITY_TYPE_SWING_HIGH)
      {
         if(currentBar.high > pool.priceLevel && currentBar.close <= pool.priceLevel)
         {
            outSweep.id               = m_nextSweepId++;
            outSweep.poolId           = pool.id;
            outSweep.sweepType        = SWEEP_BEARISH;
            outSweep.liquidityType    = pool.type;
            outSweep.sweepPrice       = currentBar.high;
            outSweep.penetrationDepth = (currentBar.high - pool.priceLevel) / (pointVal * 10.0);
            outSweep.sweepStrength    = MathMin(outSweep.penetrationDepth * 10.0, 100.0);
            outSweep.sweepTime        = currentBar.time;
            outSweep.timeframe        = pool.timeframe;
            return true;
         }
      }

      // 2. Bullish Sweep (Sell-Side Liquidity / EQL / Swing Low swept by low wick)
      if(pool.type == LIQUIDITY_TYPE_EQUAL_LOWS || pool.type == LIQUIDITY_TYPE_SELLSIDE || pool.type == LIQUIDITY_TYPE_SWING_LOW)
      {
         if(currentBar.low < pool.priceLevel && currentBar.close >= pool.priceLevel)
         {
            outSweep.id               = m_nextSweepId++;
            outSweep.poolId           = pool.id;
            outSweep.sweepType        = SWEEP_BULLISH;
            outSweep.liquidityType    = pool.type;
            outSweep.sweepPrice       = currentBar.low;
            outSweep.penetrationDepth = (pool.priceLevel - currentBar.low) / (pointVal * 10.0);
            outSweep.sweepStrength    = MathMin(outSweep.penetrationDepth * 10.0, 100.0);
            outSweep.sweepTime        = currentBar.time;
            outSweep.timeframe        = pool.timeframe;
            return true;
         }
      }

      return false;
   }
};
