//+------------------------------------------------------------------+
//|                                                 FVGValidator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "FVGTypes.mqh"

/// @class CFVGValidator
/// @brief Sanitizes detected Fair Value Gap price coordinates.
class CFVGValidator
{
public:
   static bool IsValidGap(const SFairValueGap &gap)
   {
      return (gap.id > 0 && gap.upperPrice > gap.lowerPrice && gap.gapSize > 0.0);
   }
};
