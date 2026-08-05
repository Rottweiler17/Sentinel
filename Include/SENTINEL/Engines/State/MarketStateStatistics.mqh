//+------------------------------------------------------------------+
//|                                          MarketStateStatistics.mqh|
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CMarketStateStatistics
/// @brief Tracks context framework analysis diagnostic counters.
class CMarketStateStatistics
{
private:
   int m_totalAnalyzed;
   int m_transitionsCount;

public:
   CMarketStateStatistics() : m_totalAnalyzed(0), m_transitionsCount(0) {}

   void RecordAnalysis()        { m_totalAnalyzed++; }
   void RecordTransition()      { m_transitionsCount++; }

   int TotalAnalyzed()    const { return m_totalAnalyzed; }
   int TransitionsCount() const { return m_transitionsCount; }

   void Reset()
   {
      m_totalAnalyzed    = 0;
      m_transitionsCount = 0;
   }
};
