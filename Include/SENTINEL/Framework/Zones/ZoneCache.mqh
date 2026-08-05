//+------------------------------------------------------------------+
//|                                                    ZoneCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ZoneTypes.mqh"
#include "../../Memory/RingBuffer.mqh"

/// @class CZoneCache
/// @brief Fast $O(1)$ ring buffer cache storing active, historical, merged, and expired zones.
class CZoneCache
{
private:
   CRingBuffer<SGenericZone> m_activeZones;
   CRingBuffer<SGenericZone> m_expiredZones;
   CRingBuffer<SGenericZone> m_mergedZones;

public:
   CZoneCache(int capacity = 500)
      : m_activeZones(capacity, true),
        m_expiredZones(capacity, true),
        m_mergedZones(capacity, true)
   {}

   bool AddActiveZone(const SGenericZone &zone)   { return m_activeZones.Push(zone); }
   bool AddExpiredZone(const SGenericZone &zone)  { return m_expiredZones.Push(zone); }
   bool AddMergedZone(const SGenericZone &zone)   { return m_mergedZones.Push(zone); }

   bool GetActiveZone(int index, SGenericZone &outZone) const { return m_activeZones.Get(index, outZone); }
   bool GetLatestActiveZone(SGenericZone &outZone)       const { return m_activeZones.Back(outZone); }

   /// @brief Searches active zones for nearest support below current price.
   bool FindNearestSupport(double currentPrice, SGenericZone &outSupport) const
   {
      double minDiff = 999999.0;
      bool found = false;
      int count = m_activeZones.Size();

      for(int i = 0; i < count; i++)
      {
         SGenericZone zone;
         if(m_activeZones.Get(i, zone) && zone.lifecycleState == ZONE_LIFECYCLE_ACTIVE)
         {
            if(zone.upperPrice < currentPrice)
            {
               double diff = currentPrice - zone.upperPrice;
               if(diff < minDiff)
               {
                  minDiff = diff;
                  outSupport = zone;
                  found = true;
               }
            }
         }
      }
      return found;
   }

   /// @brief Searches active zones for nearest resistance above current price.
   bool FindNearestResistance(double currentPrice, SGenericZone &outResistance) const
   {
      double minDiff = 999999.0;
      bool found = false;
      int count = m_activeZones.Size();

      for(int i = 0; i < count; i++)
      {
         SGenericZone zone;
         if(m_activeZones.Get(i, zone) && zone.lifecycleState == ZONE_LIFECYCLE_ACTIVE)
         {
            if(zone.lowerPrice > currentPrice)
            {
               double diff = zone.lowerPrice - currentPrice;
               if(diff < minDiff)
               {
                  minDiff = diff;
                  outResistance = zone;
                  found = true;
               }
            }
         }
      }
      return found;
   }

   int ActiveZonesCount()  const { return m_activeZones.Size(); }
   int ExpiredZonesCount() const { return m_expiredZones.Size(); }
   int MergedZonesCount()  const { return m_mergedZones.Size(); }

   void Clear()
   {
      m_activeZones.Clear();
      m_expiredZones.Clear();
      m_mergedZones.Clear();
   }
};
