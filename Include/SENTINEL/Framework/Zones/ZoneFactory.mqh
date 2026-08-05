//+------------------------------------------------------------------+
//|                                                  ZoneFactory.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ZoneTypes.mqh"

/// @class CZoneFactory
/// @brief Factory class for instantiating generic SGenericZone objects.
class CZoneFactory
{
private:
   static ulong m_nextZoneId;

public:
   static SGenericZone CreateZone(ENUM_ZONE_CATEGORY cat, double upper, double lower, ENUM_TIMEFRAMES tf, datetime createTime)
   {
      SGenericZone zone;
      zone.id             = ++m_nextZoneId;
      zone.category       = cat;
      zone.lifecycleState = ZONE_LIFECYCLE_CREATED;
      zone.priority       = ZONE_PRIORITY_NORMAL;
      zone.timeframe      = tf;
      zone.upperPrice     = MathMax(upper, lower);
      zone.lowerPrice     = MathMin(upper, lower);
      zone.CalculateMidPrice();
      zone.creationTime   = createTime;
      zone.strength       = 50.0;
      zone.confidence     = 80.0;
      zone.touchCount     = 0;
      zone.retestCount    = 0;
      zone.mergeCount     = 0;
      zone.mergedIntoId   = 0;
      zone.metadataJson   = "";
      return zone;
   }
};

ulong CZoneFactory::m_nextZoneId = 0;
