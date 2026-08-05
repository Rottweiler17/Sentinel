//+------------------------------------------------------------------+
//|                                             PressureAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "OrderFlowConfiguration.mqh"

/// @class CPressureAnalyzer
/// @brief Estimates framework-derived buying and selling pressure metrics.
class CPressureAnalyzer
{
public:
   /// @brief Analyzes buying/selling pressure balance from context candle attributes.
   static void AnalyzePressure(const SMarketContext &context, double &outBuyPress, double &outSellPress)
   {
      double bid = context.marketData.bid;
      double ask = context.marketData.ask;
      double avgVol = context.volume.rollingAverageVolume;
      double curReal = context.volume.currentRealVolume;

      // Safe fallback
      if(bid <= 0.0 || (ask - bid) <= 0.0)
      {
         outBuyPress  = 50.0;
         outSellPress = 50.0;
         return;
      }

      // Estimate pressure using spread ratio and current volume trend
      double trendFactor = (context.structure.externalTrend == TREND_BULLISH) ? 1.2 : 
                           (context.structure.externalTrend == TREND_BEARISH) ? 0.8 : 1.0;

      double rawBuy = 50.0 * trendFactor;
      if(context.volume.volumeState == VOLUME_STATE_SPIKE)
         rawBuy *= 1.3;

      outBuyPress  = MathMin(MathMax(rawBuy, 10.0), 90.0);
      outSellPress = 100.0 - outBuyPress;
   }
};
