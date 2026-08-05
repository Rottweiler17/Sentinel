//+------------------------------------------------------------------+
//|                                              EqualLowDetector.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "LiquidityTypes.mqh"

/// @class CEqualLowDetector
/// @brief Detects Equal Lows (EQL) liquidity pools within a configurable price tolerance.
class CEqualLowDetector
{
private:
   double m_tolerancePips;
   ulong  m_nextPoolId;

public:
   CEqualLowDetector(double tolerancePips = 3.0)
      : m_tolerancePips(tolerancePips > 0.0 ? tolerancePips : 3.0), m_nextPoolId(1)
   {}

   /// @brief Evaluates two swing lows for Equal Low (EQL) alignment.
   bool DetectEQL(const SSwingPoint &low1, const SSwingPoint &low2, double pointVal, SLiquidityPool &outPool)
   {
      if(low1.type != SWING_TYPE_LOW || low2.type != SWING_TYPE_LOW)
         return false;

      double diffPips = MathAbs(low1.price - low2.price) / (pointVal * 10.0);
      if(diffPips <= m_tolerancePips)
      {
         outPool.id              = m_nextPoolId++;
         outPool.type            = LIQUIDITY_TYPE_EQUAL_LOWS;
         outPool.strength        = LIQUIDITY_STRENGTH_STRONG;
         outPool.timeframe       = low1.timeframe;
         outPool.priceLevel      = MathMin(low1.price, low2.price);
         outPool.upperBound      = outPool.priceLevel + (m_tolerancePips * pointVal * 10.0);
         outPool.lowerBound      = outPool.priceLevel - (m_tolerancePips * pointVal * 10.0);
         outPool.touchCount      = 2;
         outPool.estimatedVolume = 1000.0;
         outPool.creationTime    = MathMax(low1.time, low2.time);
         outPool.lastTouchTime   = outPool.creationTime;
         outPool.isConsumed      = false;
         outPool.isSwept         = false;
         return true;
      }
      return false;
   }
};
