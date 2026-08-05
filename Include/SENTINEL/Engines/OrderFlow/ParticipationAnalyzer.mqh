//+------------------------------------------------------------------+
//|                                        ParticipationAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"

/// @class CParticipationAnalyzer
/// @brief Analyzes market participant levels from relative volumes.
class CParticipationAnalyzer
{
public:
   static double EstimateParticipation(const SMarketContext &context)
   {
      double rVol = context.volume.relativeVolume;
      if(rVol <= 0.0) return 0.0;

      // Participation rate normalized to 0.0 - 100.0% range
      double score = rVol * 50.0;
      return MathMin(MathMax(score, 10.0), 100.0);
   }
};
