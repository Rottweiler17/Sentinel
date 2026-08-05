//+------------------------------------------------------------------+
//|                                      InternalStructureAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "StructureTypes.mqh"
#include "TrendAnalyzer.mqh"

/// @class CInternalStructureAnalyzer
/// @brief Analyzes minor swing structure and sub-trend progression.
class CInternalStructureAnalyzer
{
private:
   ENUM_TREND_TYPE m_internalTrend;

public:
   CInternalStructureAnalyzer() : m_internalTrend(TREND_UNKNOWN) {}

   void Update(const SSwingPoint &lastMinorHigh, const SSwingPoint &prevMinorHigh,
               const SSwingPoint &lastMinorLow,  const SSwingPoint &prevMinorLow)
   {
      m_internalTrend = CTrendAnalyzer::EvaluateTrend(lastMinorHigh, prevMinorHigh, lastMinorLow, prevMinorLow);
   }

   ENUM_TREND_TYPE InternalTrend() const { return m_internalTrend; }
};
