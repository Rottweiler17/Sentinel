//+------------------------------------------------------------------+
//|                                           AbsorptionEstimator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "OrderFlowTypes.mqh"

/// @class CAbsorptionEstimator
/// @brief Estimates market limit order absorption dynamics near active zones.
class CAbsorptionEstimator
{
public:
   static ENUM_ABSORPTION_STATE EstimateAbsorption(const SMarketContext &context)
   {
      // Estimate absorption if testing a zone with high volume
      if(context.zones.activeZonesCount > 0 && context.volume.volumeState == VOLUME_STATE_SPIKE)
      {
         if(context.structure.externalTrend == TREND_BULLISH)
            return ABSORPTION_BULLISH;
         if(context.structure.externalTrend == TREND_BEARISH)
            return ABSORPTION_BEARISH;
      }

      return ABSORPTION_NONE;
   }
};
