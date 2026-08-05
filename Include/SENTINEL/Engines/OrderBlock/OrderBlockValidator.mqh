//+------------------------------------------------------------------+
//|                                           OrderBlockValidator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "OrderBlockTypes.mqh"

/// @class COrderBlockValidator
/// @brief Sanitizes order block bounds and pricing validations.
class COrderBlockValidator
{
public:
   static bool IsValidBlock(const SOrderBlock &block)
   {
      return (block.id > 0 && block.upperPrice > block.lowerPrice && block.midPrice > 0.0);
   }
};
