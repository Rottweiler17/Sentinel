//+------------------------------------------------------------------+
//|                                    SellSideLiquidityDetector.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "LiquidityTypes.mqh"

/// @class CSellSideLiquidityDetector
/// @brief Identifies Sell-Side Liquidity (SSL) pools resting below swing lows and Equal Lows.
class CSellSideLiquidityDetector
{
private:
   ulong m_nextPoolId;

public:
   CSellSideLiquidityDetector() : m_nextPoolId(200) {}

   bool CreateSSLFromSwing(const SSwingPoint &swingLow, SLiquidityPool &outPool)
   {
      if(swingLow.type != SWING_TYPE_LOW) return false;

      outPool.id                  = m_nextPoolId++;
      outPool.type                = LIQUIDITY_TYPE_SELLSIDE;
      outPool.strength            = LIQUIDITY_STRENGTH_NORMAL;
      outPool.lifecycleState      = LIQUIDITY_STATE_ACTIVE;
      outPool.timeframe           = swingLow.timeframe;
      outPool.priceLevel          = swingLow.price;
      outPool.upperBound          = swingLow.price;
      outPool.lowerBound          = swingLow.price * 0.9995;
      outPool.touchCount          = 1;
      outPool.estimatedVolume     = 500.0;
      outPool.confidenceScore     = 85.0;
      outPool.sourceDescription   = "Swing Low SSL";
      outPool.nearestOrderBlockId = 0;
      outPool.nearestFVGId        = 0;
      outPool.nearestSessionHigh  = 0.0;
      outPool.nearestSessionLow   = 0.0;
      outPool.creationTime        = swingLow.time;
      outPool.lastTouchTime       = swingLow.time;
      outPool.isConsumed          = false;
      outPool.isSwept             = false;
      return true;
   }
};
