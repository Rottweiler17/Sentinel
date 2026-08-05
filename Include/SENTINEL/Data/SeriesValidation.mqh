//+------------------------------------------------------------------+
//|                                             SeriesValidation.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Common/Types.mqh"
#include "../Utilities/Validation.mqh"

/// @class CSeriesValidation
/// @brief Validates historical and live OHLC candle structure and sequence sanity.
class CSeriesValidation
{
public:
   /// @brief Validates candle OHLC structure.
   static bool IsValidBar(const SBarData &bar)
   {
      if(!CValidation::IsValidPrice(bar.open) || !CValidation::IsValidPrice(bar.high) ||
         !CValidation::IsValidPrice(bar.low)  || !CValidation::IsValidPrice(bar.close))
         return false;

      // High must be highest price, Low must be lowest price
      if(bar.high < bar.low || bar.high < bar.open || bar.high < bar.close ||
         bar.low > bar.open  || bar.low > bar.close)
         return false;

      return true;
   }
};
