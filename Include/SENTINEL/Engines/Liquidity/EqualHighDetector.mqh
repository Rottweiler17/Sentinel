//+------------------------------------------------------------------+
//|                                             EqualHighDetector.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "LiquidityTypes.mqh"

/// @class CEqualHighDetector
/// @brief Detects Equal Highs (EQH) liquidity pools within a configurable price tolerance.
class CEqualHighDetector
{
private:
   double m_tolerancePips;
   ulong  m_nextPoolId;

public:
   CEqualHighDetector(double tolerancePips = 3.0)
      : m_tolerancePips(tolerancePips > 0.0 ? tolerancePips : 3.0), m_nextPoolId(1)
   {}

   /// @brief Evaluates two swing highs for Equal High (EQH) alignment.
   bool DetectEQH(const SSwingPoint &high1, const SSwingPoint &high2, double pointVal, SLiquidityPool &outPool)
   {
      if(high1.type != SWING_TYPE_HIGH || high2.type != SWING_TYPE_HIGH)
         return false;

      double diffPips = MathAbs(high1.price - high2.price) / (pointVal * 10.0);
      if(diffPips <= m_tolerancePips)
      {
         outPool.id                  = m_nextPoolId++;
         outPool.type                = LIQUIDITY_TYPE_EQUAL_HIGHS;
         outPool.strength            = LIQUIDITY_STRENGTH_STRONG;
         outPool.lifecycleState      = LIQUIDITY_STATE_ACTIVE;
         outPool.timeframe           = high1.timeframe;
         outPool.priceLevel          = MathMax(high1.price, high2.price);
         outPool.upperBound          = outPool.priceLevel + (m_tolerancePips * pointVal * 10.0);
         outPool.lowerBound          = outPool.priceLevel - (m_tolerancePips * pointVal * 10.0);
         outPool.touchCount          = 2;
         outPool.estimatedVolume     = 1000.0;
         outPool.confidenceScore     = 90.0;
         outPool.sourceDescription   = "Equal Highs + External Swing";
         outPool.nearestOrderBlockId = 0;
         outPool.nearestFVGId        = 0;
         outPool.nearestSessionHigh  = 0.0;
         outPool.nearestSessionLow   = 0.0;
         outPool.creationTime        = MathMax(high1.time, high2.time);
         outPool.lastTouchTime       = outPool.creationTime;
         outPool.isConsumed          = false;
         outPool.isSwept             = false;
         return true;
      }
      return false;
   }
};
