//+------------------------------------------------------------------+
//|                                         TimeSynchronization.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CTimeSynchronization
/// @brief Tracks server time, local time, and evaluates clock drift.
class CTimeSynchronization
{
private:
   datetime m_lastServerTime;
   datetime m_lastLocalTime;
   int      m_driftSeconds;

public:
   CTimeSynchronization()
      : m_lastServerTime(0), m_lastLocalTime(0), m_driftSeconds(0)
   {}

   /// @brief Updates time synchronization records.
   void Update()
   {
      m_lastServerTime = TimeCurrent();
      m_lastLocalTime  = TimeLocal();
      m_driftSeconds   = (int)(m_lastServerTime - m_lastLocalTime);
   }

   datetime ServerTime() const { return m_lastServerTime; }
   datetime LocalTime()  const { return m_lastLocalTime; }
   int TimeDriftSeconds() const { return m_driftSeconds; }
};
