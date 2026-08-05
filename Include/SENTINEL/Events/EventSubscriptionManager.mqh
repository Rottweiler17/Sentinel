//+------------------------------------------------------------------+
//|                                     EventSubscriptionManager.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Common/Interfaces.mqh"
#include <Arrays/ArrayObj.mqh>

/// @class CSubscriptionNode
/// @brief Internal container mapping an IEventListener pointer to a specific event type.
class CSubscriptionNode : public CObject
{
public:
   ENUM_SENTINEL_EVENT_TYPE m_eventType;
   IEventListener          *m_listener;

   CSubscriptionNode(ENUM_SENTINEL_EVENT_TYPE eventType, IEventListener *listener)
      : m_eventType(eventType), m_listener(listener) {}
};

/// @class CEventSubscriptionManager
/// @brief Manages listener subscriptions and retrieves registered subscribers for dispatched events.
class CEventSubscriptionManager
{
private:
   CArrayObj m_subscriptions;

public:
   CEventSubscriptionManager()
   {
      m_subscriptions.FreeMode(true);
   }

   ~CEventSubscriptionManager()
   {
      m_subscriptions.Clear();
   }

   /// @brief Subscribes an IEventListener to a specific event type.
   bool Subscribe(ENUM_SENTINEL_EVENT_TYPE eventType, IEventListener *listener)
   {
      if(listener == NULL) return false;

      // Prevent duplicate subscriptions
      int total = m_subscriptions.Total();
      for(int i = 0; i < total; i++)
      {
         CSubscriptionNode *node = m_subscriptions.At(i);
         if(node != NULL && node.m_eventType == eventType && node.m_listener == listener)
            return true;
      }

      m_subscriptions.Add(new CSubscriptionNode(eventType, listener));
      return true;
   }

   /// @brief Unsubscribes an IEventListener from a specific event type.
   bool Unsubscribe(ENUM_SENTINEL_EVENT_TYPE eventType, IEventListener *listener)
   {
      if(listener == NULL) return false;

      int total = m_subscriptions.Total();
      for(int i = 0; i < total; i++)
      {
         CSubscriptionNode *node = m_subscriptions.At(i);
         if(node != NULL && node.m_eventType == eventType && node.m_listener == listener)
         {
            m_subscriptions.Delete(i);
            return true;
         }
      }
      return false;
   }

   /// @brief Dispatches an event directly to all subscribed listeners.
   void DispatchToSubscribers(const SSentinelEvent &event)
   {
      int total = m_subscriptions.Total();
      for(int i = 0; i < total; i++)
      {
         CSubscriptionNode *node = m_subscriptions.At(i);
         if(node != NULL && node.m_eventType == event.type)
         {
            if(CheckPointer(node.m_listener) != POINTER_INVALID)
            {
               node.m_listener.OnEvent(event);
            }
         }
      }
   }

   /// @brief Returns the total number of active subscriptions.
   int TotalSubscriptions() const { return m_subscriptions.Total(); }
};
