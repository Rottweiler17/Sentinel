//+------------------------------------------------------------------+
//|                                      ExternalStructureAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "StructureTypes.mqh"
#include "TrendAnalyzer.mqh"

/// @class CExternalStructureAnalyzer
/// @brief Analyzes major swing structure and primary macro trend progression.
class CExternalStructureAnalyzer
{
private:
   ENUM_TREND_TYPE m_externalTrend;

public:
   CExternalStructureAnalyzer() : m_externalTrend(TREND_UNKNOWN) {}

   void Update(const SSwingPoint &lastMajorHigh, const SSwingPoint &prevMajorHigh,
               const SSwingPoint &lastMajorLow,  const SSwingPoint &prevMajorLow)
   {
      m_externalTrend = CTrendAnalyzer::EvaluateTrend(lastMajorHigh, prevMajorHigh, lastMajorLow, prevMajorLow);
   }

   ENUM_TREND_TYPE ExternalTrend() const { return m_externalTrend; }
};
