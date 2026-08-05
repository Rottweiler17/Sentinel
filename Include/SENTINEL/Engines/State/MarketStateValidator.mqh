//+------------------------------------------------------------------+
//|                                           MarketStateValidator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "MarketStateSnapshot.mqh"

/// @class CMarketStateValidator
/// @brief Validates price ranges and state codes.
class CMarketStateValidator
{
public:
   static bool IsValidState(ENUM_MARKET_ENVIRONMENT_STATE state)
   {
      return (state != STATE_ENV_UNKNOWN);
   }
};
