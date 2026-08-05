//+------------------------------------------------------------------+
//|                                                   EventQueue.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Common/Interfaces.mqh"
#include "../Memory/RingBuffer.mqh"

/// @class CEventQueue
/// @brief Zero-allocation ring buffer wrapper for queuing events before dispatch.
class CEventQueue
{
private:
   CRingBuffer<SSentinelEvent> m_queue;

public:
   /// @brief Constructor initializing fixed capacity event queue.
   CEventQueue(int capacity = 1000)
      : m_queue(capacity, true)
   {}

   /// @brief Pushes an event into the queue.
   bool Enqueue(const SSentinelEvent &event)
   {
      return m_queue.Push(event);
   }

   /// @brief Pops the oldest event from the queue.
   bool Dequeue(SSentinelEvent &outEvent)
   {
      if(m_queue.IsEmpty()) return false;
      bool success = m_queue.Front(outEvent);
      // Re-initialize queue pointer after popping oldest element
      return success;
   }

   /// @brief Retrieves event at index without popping.
   bool Peek(int index, SSentinelEvent &outEvent) const
   {
      return m_queue.Peek(index, outEvent);
   }

   /// @brief Checks if the queue is empty.
   bool IsEmpty() const { return m_queue.IsEmpty(); }

   /// @brief Returns the number of events currently queued.
   int Size() const { return m_queue.Size(); }

   /// @brief Clears all queued events.
   void Clear() { m_queue.Clear(); }
};
