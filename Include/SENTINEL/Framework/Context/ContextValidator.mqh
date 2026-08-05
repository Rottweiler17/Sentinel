//+------------------------------------------------------------------+
//|                                             ContextValidator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "MarketContext.mqh"

/// @class CContextValidator
/// @brief Verifies consistency of aggregated market context snap elements.
class CContextValidator
{
public:
   /// @brief Checks if context snapshots are valid and aligned by symbol/timeframe.
   static bool IsValidContext(const SMarketContext &context)
   {
      if(context.contextId == 0) return false;
      if(context.marketData.bid <= 0.0) return false;

      // Symbol match alignment check
      if(context.marketData.symbol != "" && context.structure.latestSwingHigh.type != SWING_TYPE_NONE)
      {
         if(context.marketData.timeframe != context.structure.timeframe)
            return false;
      }

      return true;
   }
};
