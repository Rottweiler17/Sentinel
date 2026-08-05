//+------------------------------------------------------------------+
//|                                          LiquidityClassifier.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "LiquidityTypes.mqh"

/// @class CLiquidityClassifier
/// @brief Classifies liquidity pool strength based on touch frequency and volume estimation.
class CLiquidityClassifier
{
public:
   /// @brief Evaluates strength classification for a liquidity pool.
   static ENUM_LIQUIDITY_STRENGTH ClassifyStrength(int touchCount, double estimatedVolume, ENUM_TIMEFRAMES tf)
   {
      // Higher touch count and HTF = stronger institutional liquidity pool
      if(touchCount >= 4 || (touchCount >= 3 && tf >= PERIOD_H1))
         return LIQUIDITY_STRENGTH_INSTITUTIONAL;

      if(touchCount >= 3 || (touchCount >= 2 && tf >= PERIOD_H1))
         return LIQUIDITY_STRENGTH_EXTREME;

      if(touchCount >= 2)
         return LIQUIDITY_STRENGTH_STRONG;

      if(touchCount == 1)
         return LIQUIDITY_STRENGTH_NORMAL;

      return LIQUIDITY_STRENGTH_WEAK;
   }
};
