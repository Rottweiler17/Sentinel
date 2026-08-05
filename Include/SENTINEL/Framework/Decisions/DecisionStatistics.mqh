//+------------------------------------------------------------------+
//|                                           DecisionStatistics.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CDecisionStatistics
/// @brief Tracks diagnostic counters for decision evaluations.
class CDecisionStatistics
{
private:
   int m_totalEvaluated;
   int m_favorableOutcomes;

public:
   CDecisionStatistics() : m_totalEvaluated(0), m_favorableOutcomes(0) {}

   void RecordEvaluation()       { m_totalEvaluated++; }
   void RecordFavorable()        { m_favorableOutcomes++; }

   int TotalEvaluated()    const { return m_totalEvaluated; }
   int FavorableOutcomes() const { return m_favorableOutcomes; }

   void Reset()
   {
      m_totalEvaluated    = 0;
      m_favorableOutcomes = 0;
   }
};
