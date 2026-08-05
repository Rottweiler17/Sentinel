//+------------------------------------------------------------------+
//|                                             VolumeStatistics.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CVolumeStatistics
/// @brief Tracks rolling average volume, session volume, daily volume, and rate of change.
class CVolumeStatistics
{
private:
   double m_rollingSum;
   int    m_period;
   double m_history[];
   int    m_currentIndex;
   int    m_count;

   double m_sessionVolume;
   double m_dailyVolume;

   datetime m_lastDayTime;
   int      m_lastSessionId;

public:
   CVolumeStatistics(int period = 20)
      : m_rollingSum(0.0), m_period(period > 0 ? period : 20), m_currentIndex(0), m_count(0),
        m_sessionVolume(0.0), m_dailyVolume(0.0), m_lastDayTime(0), m_lastSessionId(-1)
   {
      ArrayResize(m_history, m_period);
      ArrayInitialize(m_history, 0.0);
   }

   void Update(double volume, datetime timeVal, int sessionId)
   {
      // 1. Rolling average volume calculation
      if(m_count < m_period)
      {
         m_rollingSum += volume;
         m_history[m_currentIndex] = volume;
         m_currentIndex = (m_currentIndex + 1) % m_period;
         m_count++;
      }
      else
      {
         m_rollingSum = m_rollingSum - m_history[m_currentIndex] + volume;
         m_history[m_currentIndex] = volume;
         m_currentIndex = (m_currentIndex + 1) % m_period;
      }

      // 2. Daily volume reset / accumulation
      MqlDateTime dt;
      TimeToStruct(timeVal, dt);
      datetime dayStart = timeVal - (dt.hour * 3600 + dt.min * 60 + dt.sec);

      if(dayStart != m_lastDayTime)
      {
         m_dailyVolume = volume;
         m_lastDayTime = dayStart;
      }
      else
      {
         m_dailyVolume += volume;
      }

      // 3. Session volume reset / accumulation
      if(sessionId != m_lastSessionId)
      {
         m_sessionVolume = volume;
         m_lastSessionId = sessionId;
      }
      else
      {
         m_sessionVolume += volume;
      }
   }

   double RollingAverage() const
   {
      if(m_count <= 0) return 0.0;
      return m_rollingSum / m_count;
   }

   double SessionVolume() const { return m_sessionVolume; }
   double DailyVolume()   const { return m_dailyVolume; }
};
