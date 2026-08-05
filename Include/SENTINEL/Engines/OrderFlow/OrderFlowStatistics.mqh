//+------------------------------------------------------------------+
//|                                          OrderFlowStatistics.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class COrderFlowStatistics
/// @brief Tracks generic diagnostic counters for order flow estimations.
class COrderFlowStatistics
{
private:
   int m_totalEvaluated;
   int m_spikesTracked;

public:
   COrderFlowStatistics() : m_totalEvaluated(0), m_spikesTracked(0) {}

   void RecordEvaluation()       { m_totalEvaluated++; }
   void RecordSpike()            { m_spikesTracked++; }

   int TotalEvaluated()    const { return m_totalEvaluated; }
   int SpikesTracked()     const { return m_spikesTracked; }

   void Reset()
   {
      m_totalEvaluated = 0;
      m_spikesTracked  = 0;
   }
};
