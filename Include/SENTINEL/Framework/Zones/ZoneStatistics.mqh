//+------------------------------------------------------------------+
//|                                               ZoneStatistics.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ZoneTypes.mqh"

/// @class CZoneStatistics
/// @brief Tracks zone framework metrics and calculates telemetry scores.
class CZoneStatistics
{
private:
   int    m_totalCreated;
   int    m_retested;
   int    m_merged;
   int    m_mitigated;
   int    m_consumed;
   int    m_expired;
   double m_qualityScore;

public:
   CZoneStatistics()
   {
      Reset();
   }

   void RecordCreated()   { m_totalCreated++; RecalculateQuality(); }
   void RecordRetested()  { m_retested++; RecalculateQuality(); }
   void RecordMerged()    { m_merged++; RecalculateQuality(); }
   void RecordMitigated() { m_mitigated++; RecalculateQuality(); }
   void RecordConsumed()  { m_consumed++; RecalculateQuality(); }
   void RecordExpired()   { m_expired++; RecalculateQuality(); }

   double QualityScore() const { return m_qualityScore; }

   void Reset()
   {
      m_totalCreated = 0;
      m_retested     = 0;
      m_merged       = 0;
      m_mitigated    = 0;
      m_consumed     = 0;
      m_expired      = 0;
      m_qualityScore = 100.0;
   }

private:
   void RecalculateQuality()
   {
      if(m_totalCreated <= 0) { m_qualityScore = 100.0; return; }
      double retestRatio = (double)m_retested / (double)m_totalCreated;
      m_qualityScore = MathMin(retestRatio * 100.0, 100.0);
   }
};
