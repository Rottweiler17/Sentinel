//+------------------------------------------------------------------+
//|                                          LiquidityStatistics.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "LiquidityTypes.mqh"
#include "LiquidityStrengthAnalyzer.mqh"

/// @class CLiquidityStatistics
/// @brief Tracks liquidity pool counts, sweep counts, and telemetry scores.
class CLiquidityStatistics
{
private:
   SLiquidityStats m_stats;

public:
   CLiquidityStatistics()
   {
      Reset();
   }

   void RecordPoolDetected()
   {
      m_stats.totalPoolsDetected++;
      m_stats.activePoolsCount++;
      RecalculateQuality();
   }

   void RecordSweep()
   {
      m_stats.totalSweepsDetected++;
      if(m_stats.activePoolsCount > 0) m_stats.activePoolsCount--;
      m_stats.consumedPoolsCount++;
      RecalculateQuality();
   }

   const SLiquidityStats* GetStats() const { return &m_stats; }

   void Reset()
   {
      m_stats.totalPoolsDetected    = 0;
      m_stats.totalSweepsDetected   = 0;
      m_stats.activePoolsCount      = 0;
      m_stats.consumedPoolsCount    = 0;
      m_stats.liquidityQualityScore = 100.0;
   }

private:
   void RecalculateQuality()
   {
      m_stats.liquidityQualityScore = CLiquidityStrengthAnalyzer::CalculateQualityScore(
         m_stats.totalPoolsDetected, m_stats.totalSweepsDetected, m_stats.activePoolsCount
      );
   }
};
