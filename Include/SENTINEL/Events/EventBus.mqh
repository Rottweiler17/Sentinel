//+------------------------------------------------------------------+
//|                                                     EventBus.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "EventSubscriptionManager.mqh"
#include "EventQueue.mqh"
#include "../Logging/Logger.mqh"

/// @class CEventBus
/// @brief Central messaging bus coordinating event publication, queuing, and listener dispatching.
class CEventBus
{
private:
   CEventSubscriptionManager m_subManager;
   CEventQueue                m_queue;

public:
   CEventBus(int queueCapacity = 1000)
      : m_queue(queueCapacity)
   {}

   ~CEventBus() {}

   /// @brief Subscribes a listener to a specific event type.
   bool Subscribe(ENUM_SENTINEL_EVENT_TYPE eventType, IEventListener *listener)
   {
      return m_subManager.Subscribe(eventType, listener);
   }

   /// @brief Unsubscribes a listener from an event type.
   bool Unsubscribe(ENUM_SENTINEL_EVENT_TYPE eventType, IEventListener *listener)
   {
      return m_subManager.Unsubscribe(eventType, listener);
   }

   /// @brief Publishes an event directly (synchronous immediate dispatch).
   void Publish(const SSentinelEvent &event)
   {
      m_subManager.DispatchToSubscribers(event);
   }

   /// @brief Queues an event for asynchronous batch processing.
   bool QueueEvent(const SSentinelEvent &event)
   {
      return m_queue.Enqueue(event);
   }

   /// @brief Flushes and dispatches all queued events.
   void ProcessQueue()
   {
      SSentinelEvent event;
      while(!m_queue.IsEmpty())
      {
         if(m_queue.Peek(0, event))
         {
            m_subManager.DispatchToSubscribers(event);
         }
         // Clear flushed items from queue
         m_queue.Clear();
      }
   }

   /// @brief Returns total active subscriptions.
   int SubscriptionCount() const { return m_subManager.TotalSubscriptions(); }
};
