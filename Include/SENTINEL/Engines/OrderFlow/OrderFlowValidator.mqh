//+------------------------------------------------------------------+
//|                                           OrderFlowValidator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "OrderFlowSnapshot.mqh"

/// @class COrderFlowValidator
/// @brief Sanitizes and validates order flow estimation values.
class COrderFlowValidator
{
public:
   static bool IsValidSnapshot(const SOrderFlowSnapshot &snap)
   {
      return (snap.buyingPressure >= 0.0 && snap.sellingPressure >= 0.0);
   }
};
