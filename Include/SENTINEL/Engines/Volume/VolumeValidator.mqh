//+------------------------------------------------------------------+
//|                                              VolumeValidator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "VolumeSnapshot.mqh"

/// @class CVolumeValidator
/// @brief Sanitizes and validates volume inputs.
class CVolumeValidator
{
public:
   static bool IsValidVolume(double volume)
   {
      return (volume >= 0.0);
   }
};
