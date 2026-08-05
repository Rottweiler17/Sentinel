//+------------------------------------------------------------------+
//|                                             ConfluenceEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CConfluenceEngine
/// @brief Measures agreement/alignment across all scoring dimensions.
class CConfluenceEngine
{
public:
   static double CalculateConfluence(double trend, double liq, double vol, double orderFlow, double session)
   {
      // Simple variance-based agreement metric
      double mean = (trend + liq + vol + orderFlow + session) / 5.0;
      double varSum = MathPow(trend - mean, 2) + MathPow(liq - mean, 2) + 
                      MathPow(vol - mean, 2) + MathPow(orderFlow - mean, 2) + MathPow(session - mean, 2);
      double stdDev = MathSqrt(varSum / 5.0);

      // High standard deviation = low confluence, low standard deviation = high confluence
      double score = 100.0 - (stdDev * 2.0);
      return MathMin(MathMax(score, 0.0), 100.0);
   }
};
