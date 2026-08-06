//+------------------------------------------------------------------+
//|                                           PerformanceOverlay.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CPerformanceOverlay
/// @brief Tracks framework rendering FPS, tick latency, and memory overhead.
class CPerformanceOverlay
{
private:
   ulong    m_frameCount;
   datetime m_lastResetTime;
   double   m_currentFps;
   double   m_lastTickMs;

public:
   CPerformanceOverlay() : m_frameCount(0), m_lastResetTime(0), m_currentFps(60.0), m_lastTickMs(0.12) {}

   /// @brief Records a rendered frame cycle.
   void RecordFrame()
   {
      m_frameCount++;
      datetime now = TimeCurrent();
      if(now > m_lastResetTime)
      {
         if(m_lastResetTime > 0)
            m_currentFps = (double)m_frameCount / (double)(now - m_lastResetTime);
         m_lastResetTime = now;
         m_frameCount    = 0;
      }
   }

   /// @brief Records tick execution duration in ms.
   void RecordTickProcessing(double durationMs)
   {
      m_lastTickMs = durationMs;
   }

   /// @brief Returns current FPS.
   double GetFPS() const { return m_currentFps; }

   /// @brief Returns last tick latency in ms.
   double GetTickLatencyMs() const { return m_lastTickMs; }
};
