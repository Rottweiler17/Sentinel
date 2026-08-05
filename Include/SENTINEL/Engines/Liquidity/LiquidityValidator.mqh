//+------------------------------------------------------------------+
//|                                           LiquidityValidator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "LiquidityTypes.mqh"
#include "../../Utilities/Validation.mqh"

/// @class CLiquidityValidator
/// @brief Sanitizes and validates liquidity pool candidates and sweep events.
class CLiquidityValidator
{
public:
   /// @brief Validates a liquidity pool object.
   static bool IsValidPool(const SLiquidityPool &pool)
   {
      if(pool.type == LIQUIDITY_TYPE_NONE) return false;
      if(!CValidation::IsValidPrice(pool.priceLevel)) return false;
      if(pool.creationTime <= 0) return false;
      return true;
   }

   /// @brief Validates a liquidity sweep object.
   static bool IsValidSweep(const SLiquiditySweep &sweep)
   {
      if(sweep.sweepType == SWEEP_NONE) return false;
      if(!CValidation::IsValidPrice(sweep.sweepPrice)) return false;
      return true;
   }
};
