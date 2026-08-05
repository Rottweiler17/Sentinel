//+------------------------------------------------------------------+
//|                                              SwingClassifier.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "StructureTypes.mqh"

/// @class CSwingClassifier
/// @brief Classifies swing pivot points into Major (External) or Minor (Internal) structure.
class CSwingClassifier
{
public:
   /// @brief Classifies a swing candidate.
   static bool IsMajorSwing(const SSwingPoint &candidate, const SSwingPoint &lastMajorSwing, int swingLength)
   {
      if(lastMajorSwing.type == SWING_TYPE_NONE)
         return true;

      // Higher high or lower low relative to last major swing confirms Major status
      if(candidate.type == SWING_TYPE_HIGH && candidate.price > lastMajorSwing.price)
         return true;
      if(candidate.type == SWING_TYPE_LOW && candidate.price < lastMajorSwing.price)
         return true;

      // Bar distance check
      return (MathAbs(candidate.barIndex - lastMajorSwing.barIndex) >= (swingLength * 2));
   }
};
