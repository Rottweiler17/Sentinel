//+------------------------------------------------------------------+
//|                                                EventRecorder.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Common/Interfaces.mqh"
#include "../Memory/RingBuffer.mqh"
#include "../Logging/Logger.mqh"

/// @class CEventRecorder
/// @brief Records published SSentinelEvents into static ring buffer for sequence replay and debugging.
class CEventRecorder : public IEventListener
{
private:
   CRingBuffer<SSentinelEvent> m_eventLog;
   bool                        m_isRecording;

public:
   CEventRecorder(int capacity = 1000)
      : m_eventLog(capacity, true), m_isRecording(true)
   {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(!m_isRecording) return;
      m_eventLog.Push(event);
   }

   void SetRecording(bool record) { m_isRecording = record; }
   bool IsRecording() const { return m_isRecording; }

   int RecordedEventsCount() const { return m_eventLog.Size(); }

   /// @brief Replays recorded events to a target listener sequence.
   void ReplayEvents(IEventListener *targetListener)
   {
      if(targetListener == NULL) return;

      int count = m_eventLog.Size();
      CLogger::Info("EventRecorder", StringFormat("Starting event sequence replay of %d events...", count));

      for(int i = count - 1; i >= 0; i--)
      {
         SSentinelEvent event;
         if(m_eventLog.Get(i, event))
         {
            targetListener.OnEvent(event);
         }
      }
      CLogger::Info("EventRecorder", "Event sequence replay complete.");
   }

   void Clear() { m_eventLog.Clear(); }
};
