//+------------------------------------------------------------------+
//|                                         ZoneLifecycleManager.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ZoneTypes.mqh"
#include "ZoneEvents.mqh"
#include "../../Events/EventBus.mqh"

/// @class CZoneLifecycleManager
/// @brief Coordinates explicit lifecycle state transitions and notifies CEventBus.
class CZoneLifecycleManager
{
private:
   CEventBus *m_eventBusRef;

public:
   CZoneLifecycleManager(CEventBus *bus = NULL) : m_eventBusRef(bus) {}

   void SetEventBus(CEventBus *bus) { m_eventBusRef = bus; }

   /// @brief Transitions zone lifecycle state and publishes event.
   bool TransitionState(SGenericZone &zone, ENUM_ZONE_LIFECYCLE newState)
   {
      if(zone.lifecycleState == newState) return false;

      zone.lifecycleState = newState;

      if(m_eventBusRef != NULL)
      {
         ENUM_EVENT_TYPE evtType = EVENT_MKT_ZONE_CREATED;
         if(newState == ZONE_LIFECYCLE_ACTIVE)    evtType = EVENT_MKT_ZONE_CREATED;
         if(newState == ZONE_LIFECYCLE_RETESTED)  evtType = EVENT_MKT_ZONE_CREATED;
         if(newState == ZONE_LIFECYCLE_CONSUMED)  evtType = EVENT_MKT_ZONE_INVALIDATED;

         m_eventBusRef.Publish(CZoneEvents::CreateZoneEvent(evtType, zone));
      }
      return true;
   }
};
