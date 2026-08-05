//+------------------------------------------------------------------+
//|                                                   ZoneMerger.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ZoneTypes.mqh"
#include "ZoneConfiguration.mqh"

/// @class CZoneMerger
/// @brief Configurable overlapping zone merger. Consolidates overlapping price boundaries.
class CZoneMerger
{
public:
   /// @brief Evaluates whether two zones overlap and should be merged.
   static bool CanMerge(const SGenericZone &z1, const SGenericZone &z2, const CZoneConfiguration &config)
   {
      if(z1.category != z2.category) return false;
      if(z1.lifecycleState != ZONE_LIFECYCLE_ACTIVE || z2.lifecycleState != ZONE_LIFECYCLE_ACTIVE) return false;

      // Check overlap
      double overlapUpper = MathMin(z1.upperPrice, z2.upperPrice);
      double overlapLower = MathMax(z1.lowerPrice, z2.lowerPrice);

      if(overlapUpper <= overlapLower) return false; // No overlap

      double overlapHeight = overlapUpper - overlapLower;
      double minZoneHeight = MathMin(z1.Height(), z2.Height());

      double overlapPercent = (overlapHeight / minZoneHeight) * 100.0;
      return (overlapPercent >= config.OverlapPercentThreshold());
   }

   /// @brief Merges zone z2 into zone z1.
   static bool MergeZones(SGenericZone &z1, const SGenericZone &z2)
   {
      z1.upperPrice = MathMax(z1.upperPrice, z2.upperPrice);
      z1.lowerPrice = MathMin(z1.lowerPrice, z2.lowerPrice);
      z1.CalculateMidPrice();
      z1.touchCount += z2.touchCount;
      z1.mergeCount++;
      z1.strength = MathMin(z1.strength + 10.0, 100.0);
      z1.lifecycleState = ZONE_LIFECYCLE_MERGED;
      return true;
   }
};
