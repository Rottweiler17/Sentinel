//+------------------------------------------------------------------+
//|                                           StructureValidator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "StructureTypes.mqh"
#include "../../Utilities/Validation.mqh"

/// @class CStructureValidator
/// @brief Sanitizes and validates swing points, BOS triggers, and CHOCH events.
class CStructureValidator
{
public:
   /// @brief Validates a swing point candidate.
   static bool IsValidSwing(const SSwingPoint &swing)
   {
      if(swing.type == SWING_TYPE_NONE) return false;
      if(!CValidation::IsValidPrice(swing.price)) return false;
      if(swing.time <= 0) return false;
      return true;
   }

   /// @brief Validates Break of Structure (BOS) payload.
   static bool IsValidBOS(const SBOSData &bos)
   {
      if(bos.type == BREAK_NONE) return false;
      if(!CValidation::IsValidPrice(bos.breakPrice) || !CValidation::IsValidPrice(bos.brokenSwingPrice)) return false;
      return true;
   }
};
