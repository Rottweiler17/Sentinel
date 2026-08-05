//+------------------------------------------------------------------+
//|                                            SessionStatistics.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "SessionTypes.mqh"

/// @class CSessionStatistics
/// @brief Aggregates high/low/range details and tracks average session range.
class CSessionStatistics
{
private:
   SSessionStats m_stats;
   double        m_runningTotalRange;
   int           m_recordedSessionsCount;

public:
   CSessionStatistics()
      : m_runningTotalRange(0.0), m_recordedSessionsCount(0)
   {
      Reset();
   }

   void Update(double bid, datetime timeVal)
   {
      if(m_stats.openPrice <= 0.0) m_stats.openPrice = bid;
      m_stats.closePrice = bid;

      if(bid > m_stats.high || m_stats.high <= 0.0)
      {
         m_stats.high = bid;
         m_stats.highTime = timeVal;
      }
      if(bid < m_stats.low || m_stats.low <= 0.0)
      {
         m_stats.low = bid;
         m_stats.lowTime = timeVal;
      }

      m_stats.midpoint = (m_stats.high + m_stats.low) / 2.0;
      m_stats.range    = m_stats.high - m_stats.low;
   }

   void RecordSessionEnd()
   {
      if(m_stats.range > 0.0)
      {
         m_runningTotalRange += m_stats.range;
         m_recordedSessionsCount++;
      }
   }

   double AverageRange() const
   {
      if(m_recordedSessionsCount <= 0) return m_stats.range;
      return m_runningTotalRange / m_recordedSessionsCount;
   }

   const SSessionStats* GetStats() const { return &m_stats; }

   void Reset()
   {
      m_stats.high       = 0.0;
      m_stats.low        = 0.0;
      m_stats.midpoint   = 0.0;
      m_stats.range      = 0.0;
      m_stats.openPrice  = 0.0;
      m_stats.closePrice = 0.0;
      m_stats.highTime   = 0;
      m_stats.lowTime    = 0;
   }
};
