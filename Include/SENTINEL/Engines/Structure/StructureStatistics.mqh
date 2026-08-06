//+------------------------------------------------------------------+
//|                                              StructureStatistics.mqh|
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "StructureTypes.mqh"

/// @class CStructureStatistics
/// @brief Tracks and calculates structure quality scores and telemetry statistics.
class CStructureStatistics
{
private:
   SStructureStats m_stats;

public:
   CStructureStatistics()
   {
      Reset();
   }

   void RecordSwing(bool isMajor)
   {
      m_stats.totalSwingsDetected++;
      if(isMajor) m_stats.majorSwingsCount++;
      else m_stats.minorSwingsCount++;
      RecalculateQuality();
   }

   void RecordBOS()
   {
      m_stats.totalBOSDetected++;
      RecalculateQuality();
   }

   void RecordCHOCH()
   {
      m_stats.totalCHOCHDetected++;
      RecalculateQuality();
   }

   bool GetStats(SStructureStats &stats) const { stats = m_stats; return true; }
   SStructureStats GetStats() const { return m_stats; }

   void Reset()
   {
      m_stats.totalSwingsDetected   = 0;
      m_stats.totalBOSDetected      = 0;
      m_stats.totalCHOCHDetected    = 0;
      m_stats.majorSwingsCount      = 0;
      m_stats.minorSwingsCount      = 0;
      m_stats.structureQualityScore = 100.0;
   }

private:
   void RecalculateQuality()
   {
      if(m_stats.totalSwingsDetected <= 0)
      {
         m_stats.structureQualityScore = 100.0;
         return;
      }

      double cleanRatio = (double)m_stats.totalBOSDetected / (double)m_stats.totalSwingsDetected;
      m_stats.structureQualityScore = (cleanRatio * 100.0 > 100.0) ? 100.0 : (cleanRatio * 100.0);
   }
};
