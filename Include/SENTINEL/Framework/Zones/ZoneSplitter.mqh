//+------------------------------------------------------------------+
//|                                                 ZoneSplitter.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ZoneTypes.mqh"

/// @class CZoneSplitter
/// @brief Handles partial penetration boundary adjustments for generic zones.
class CZoneSplitter
{
public:
   /// @brief Adjusts zone boundary upon partial price mitigation.
   static bool MitigateZoneBoundary(SGenericZone &zone, double penetrationPrice)
   {
      if(zone.category == ZONE_CATEGORY_DEMAND || zone.category == ZONE_CATEGORY_SUPPORT)
      {
         if(penetrationPrice > zone.lowerPrice && penetrationPrice < zone.upperPrice)
         {
            zone.upperPrice = penetrationPrice;
            zone.CalculateMidPrice();
            zone.lifecycleState = ZONE_LIFECYCLE_MITIGATED;
            return true;
         }
      }
      else if(zone.category == ZONE_CATEGORY_SUPPLY || zone.category == ZONE_CATEGORY_RESISTANCE)
      {
         if(penetrationPrice > zone.lowerPrice && penetrationPrice < zone.upperPrice)
         {
            zone.lowerPrice = penetrationPrice;
            zone.CalculateMidPrice();
            zone.lifecycleState = ZONE_LIFECYCLE_MITIGATED;
            return true;
         }
      }
      return false;
   }
};
