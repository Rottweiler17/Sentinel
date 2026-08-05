//+------------------------------------------------------------------+
//|                                                ZoneValidator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ZoneTypes.mqh"
#include "ZoneConfiguration.mqh"
#include "../../Utilities/Validation.mqh"

/// @class CZoneValidator
/// @brief Validates generic zone candidates against height, age, and price boundary rules.
class CZoneValidator
{
public:
   /// @brief Evaluates zone candidate validity against configuration rules.
   static bool IsValidZone(const SGenericZone &zone, const CZoneConfiguration &config, double pointVal)
   {
      if(zone.category == ZONE_CATEGORY_UNKNOWN) return false;
      if(!CValidation::IsValidPrice(zone.upperPrice) || !CValidation::IsValidPrice(zone.lowerPrice)) return false;
      if(zone.upperPrice <= zone.lowerPrice) return false;

      double heightPips = (zone.upperPrice - zone.lowerPrice) / (pointVal * 10.0);
      if(heightPips < config.MinHeightPips() || heightPips > config.MaxHeightPips())
         return false;

      return true;
   }
};
