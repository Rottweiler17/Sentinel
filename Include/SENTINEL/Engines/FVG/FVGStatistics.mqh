//+------------------------------------------------------------------+
//|                                                FVGStatistics.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CFVGStatistics
/// @brief Tracks diagnostic counters for Fair Value Gap evaluations.
class CFVGStatistics
{
private:
   int m_totalDetected;
   int m_totalFilled;

public:
   CFVGStatistics() : m_totalDetected(0), m_totalFilled(0) {}

   void RecordDetection() { m_totalDetected++; }
   void RecordFill()      { m_totalFilled++; }

   int TotalDetected() const { return m_totalDetected; }
   int TotalFilled()    const { return m_totalFilled; }

   void Reset()
   {
      m_totalDetected = 0;
      m_totalFilled   = 0;
   }
};
