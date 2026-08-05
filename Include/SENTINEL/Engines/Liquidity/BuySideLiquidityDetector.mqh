//+------------------------------------------------------------------+
//|                                     BuySideLiquidityDetector.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "LiquidityTypes.mqh"

/// @class CBuySideLiquidityDetector
/// @brief Identifies Buy-Side Liquidity (BSL) pools resting above swing highs and Equal Highs.
class CBuySideLiquidityDetector
{
private:
   ulong m_nextPoolId;

public:
   CBuySideLiquidityDetector() : m_nextPoolId(100) {}

   bool CreateBSLFromSwing(const SSwingPoint &swingHigh, SLiquidityPool &outPool)
   {
      if(swingHigh.type != SWING_TYPE_HIGH) return false;

      outPool.id              = m_nextPoolId++;
      outPool.type            = LIQUIDITY_TYPE_BUYSIDE;
      outPool.strength        = LIQUIDITY_STRENGTH_NORMAL;
      outPool.timeframe       = swingHigh.timeframe;
      outPool.priceLevel      = swingHigh.price;
      outPool.upperBound      = swingHigh.price * 1.0005;
      outPool.lowerBound      = swingHigh.price;
      outPool.touchCount      = 1;
      outPool.estimatedVolume = 500.0;
      outPool.creationTime    = swingHigh.time;
      outPool.lastTouchTime   = swingHigh.time;
      outPool.isConsumed      = false;
      outPool.isSwept         = false;
      return true;
   }
};
