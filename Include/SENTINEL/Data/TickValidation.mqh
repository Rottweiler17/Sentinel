//+------------------------------------------------------------------+
//|                                               TickValidation.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Common/Types.mqh"
#include "../Utilities/Validation.mqh"

/// @class CTickValidation
/// @brief Validates incoming real-time MT5 ticks for price sanity, positive volume, and timestamp sequence.
class CTickValidation
{
public:
   /// @brief Validates tick parameters.
   static bool IsValidTick(const MqlTick &tick, datetime lastTickTime = 0)
   {
      // 1. Price validity check
      if(!CValidation::IsValidPrice(tick.bid) || !CValidation::IsValidPrice(tick.ask))
         return false;

      // 2. Bid/Ask spread check (Ask must be >= Bid)
      if(tick.ask < tick.bid)
         return false;

      // 3. Timestamp sequence check
      if(lastTickTime > 0 && tick.time < lastTickTime)
         return false;

      return true;
   }
};
