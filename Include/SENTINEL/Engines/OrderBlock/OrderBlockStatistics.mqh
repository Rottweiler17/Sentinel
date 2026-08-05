//+------------------------------------------------------------------+
//|                                         OrderBlockStatistics.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class COrderBlockStatistics
/// @brief Tracks diagnostic counters for order blocks.
class COrderBlockStatistics
{
private:
   int m_totalDetected;
   int m_totalMitigated;

public:
   COrderBlockStatistics() : m_totalDetected(0), m_totalMitigated(0) {}

   void RecordDetection()        { m_totalDetected++; }
   void RecordMitigation()       { m_totalMitigated++; }

   int TotalDetected()     const { return m_totalDetected; }
   int TotalMitigated()    const { return m_totalMitigated; }

   void Reset()
   {
      m_totalDetected  = 0;
      m_totalMitigated = 0;
   }
};
