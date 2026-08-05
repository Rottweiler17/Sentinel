//+------------------------------------------------------------------+
//|                                             SessionValidator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "SessionSnapshot.mqh"

/// @class CSessionValidator
/// @brief Sanitizes and validates session window timestamps.
class CSessionValidator
{
public:
   static bool IsValidSession(ENUM_MARKET_SESSION session)
   {
      return (session != SESSION_UNKNOWN);
   }
};
