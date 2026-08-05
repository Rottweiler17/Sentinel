//+------------------------------------------------------------------+
//|                                               ZoneClassifier.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ZoneTypes.mqh"

/// @class CZoneClassifier
/// @brief Evaluates priority rating and strength tier for generic price zones.
class CZoneClassifier
{
public:
   static ENUM_ZONE_PRIORITY EvaluatePriority(int touchCount, ENUM_TIMEFRAMES tf)
   {
      if(touchCount >= 4 || (touchCount >= 2 && tf >= PERIOD_H4))
         return ZONE_PRIORITY_CRITICAL;
      if(touchCount >= 3 || (touchCount >= 2 && tf >= PERIOD_H1))
         return ZONE_PRIORITY_HIGH;
      if(touchCount >= 2)
         return ZONE_PRIORITY_NORMAL;
      return ZONE_PRIORITY_LOW;
   }
};
