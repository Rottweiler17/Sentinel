//+------------------------------------------------------------------+
//|                                    LiquidityStrengthAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "LiquidityTypes.mqh"

/// @class CLiquidityStrengthAnalyzer
/// @brief Computes volume impact and liquidity quality scores for active pools.
class CLiquidityStrengthAnalyzer
{
public:
   static double CalculateQualityScore(int totalPools, int sweptPools, int activePools)
   {
      if(totalPools <= 0) return 100.0;
      double ratio = (double)sweptPools / (double)totalPools;
      return MathMin(ratio * 100.0, 100.0);
   }
};
