//+------------------------------------------------------------------+
//|                                               ZoneRepository.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ZoneTypes.mqh"
#include "ZoneCache.mqh"

/// @class CZoneRepository
/// @brief Enables lookup queries for generic zones by ID, price range, or category.
class CZoneRepository
{
private:
   CZoneCache *m_cacheRef;

public:
   CZoneRepository(CZoneCache *cache = NULL) : m_cacheRef(cache) {}

   void SetCache(CZoneCache *cache) { m_cacheRef = cache; }

   /// @brief Queries zone by ID.
   bool FindById(ulong id, SGenericZone &outZone) const
   {
      if(m_cacheRef == NULL) return false;
      int count = m_cacheRef.ActiveZonesCount();

      for(int i = 0; i < count; i++)
      {
         SGenericZone zone;
         if(m_cacheRef.GetActiveZone(i, zone) && zone.id == id)
         {
            outZone = zone;
            return true;
         }
      }
      return false;
   }
};
