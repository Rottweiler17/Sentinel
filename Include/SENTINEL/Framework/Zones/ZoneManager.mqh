//+------------------------------------------------------------------+
//|                                                  ZoneManager.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ZoneTypes.mqh"
#include "ZoneCache.mqh"
#include "ZoneMerger.mqh"
#include "ZoneSplitter.mqh"
#include "ZoneLifecycleManager.mqh"
#include "ZoneConfiguration.mqh"

/// @class CZoneManager
/// @brief Collection manager orchestrating active zones, touch retests, overlap merging, and expiration.
class CZoneManager
{
private:
   CZoneCache            *m_cacheRef;
   CZoneLifecycleManager *m_lifecycleRef;
   CZoneConfiguration    *m_configRef;

public:
   CZoneManager(CZoneCache *cache = NULL, CZoneLifecycleManager *lifecycle = NULL, CZoneConfiguration *config = NULL)
      : m_cacheRef(cache), m_lifecycleRef(lifecycle), m_configRef(config)
   {}

   void Init(CZoneCache *cache, CZoneLifecycleManager *lifecycle, CZoneConfiguration *config)
   {
      m_cacheRef     = cache;
      m_lifecycleRef = lifecycle;
      m_configRef    = config;
   }

   /// @brief Evaluates current bar for zone retest, mitigation, or consumption.
   void UpdateZonesWithCandle(const SBarData &candle)
   {
      if(m_cacheRef == NULL) return;

      int count = m_cacheRef.ActiveZonesCount();
      for(int i = 0; i < count; i++)
      {
         SGenericZone zone;
         if(m_cacheRef.GetActiveZone(i, zone) && zone.lifecycleState == ZONE_LIFECYCLE_ACTIVE)
         {
            // Retest Check
            if(candle.low <= zone.upperPrice && candle.high >= zone.lowerPrice)
            {
               zone.touchCount++;
               zone.retestCount++;
               if(m_lifecycleRef != NULL)
                  m_lifecycleRef.TransitionState(zone, ZONE_LIFECYCLE_RETESTED);
            }

            // Full Consumption Check
            if((zone.category == ZONE_CATEGORY_DEMAND || zone.category == ZONE_CATEGORY_SUPPORT) && candle.close < zone.lowerPrice)
            {
               if(m_lifecycleRef != NULL)
                  m_lifecycleRef.TransitionState(zone, ZONE_LIFECYCLE_CONSUMED);
            }
            else if((zone.category == ZONE_CATEGORY_SUPPLY || zone.category == ZONE_CATEGORY_RESISTANCE) && candle.close > zone.upperPrice)
            {
               if(m_lifecycleRef != NULL)
                  m_lifecycleRef.TransitionState(zone, ZONE_LIFECYCLE_CONSUMED);
            }
         }
      }
   }
};
