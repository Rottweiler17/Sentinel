//+------------------------------------------------------------------+
//|                                              SentinelAppMenu.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Include/SENTINEL/Visualization/VisualizationEngine.mqh"
#include "SentinelAppPerformanceTracker.mqh"

/// @class CSentinelAppMenu
/// @brief Developer panel controls & overlay toggle menu system.
class CSentinelAppMenu
{
private:
   long m_chartId;
   int  m_posX;
   int  m_posY;

public:
   CSentinelAppMenu() : m_chartId(0), m_posX(20), m_posY(30) {}

   void Initialize(long chartId, int x = 20, int y = 30)
   {
      m_chartId = chartId;
      m_posX    = x;
      m_posY    = y;
   }

   /// @brief Formats Developer Panel content string detailing state, metrics, and telemetry.
   static string FormatDeveloperPanel(const SMarketContext &context,
                                      const SSentinelAppPerformanceMetrics &perf,
                                      const SVisualizationSnapshot &visSnap)
   {
      string panel = "======================================================\n";
      panel += "       SENTINEL FRAMEWORK DEVELOPER APPLICATION       \n";
      panel += StringFormat(" Version: 1.0.0-DEV | Build: 2026.08.06 | Mode: READ-ONLY\n");
      panel += "======================================================\n";
      panel += StringFormat(" Symbol:           %-10s | Timeframe: %d min\n", _Symbol, _Period);
      panel += StringFormat(" Tick Time:        %s\n", TimeToString(context.timestamp, TIME_DATE|TIME_SECONDS));
      panel += StringFormat(" Active Session:   %-10s | Bias: %.2f\n", 
                            (context.session.sessionType == 1 ? "ASIA" : (context.session.sessionType == 2 ? "LONDON" : "NY")),
                            context.session.directionalBias);
      panel += StringFormat(" Market State:     %-10s | Trend: %s\n",
                            (context.state.stateType == 1 ? "TRENDING" : (context.state.stateType == 2 ? "EXPANSION" : "RANGING")),
                            (context.structure.trend == 1 ? "BULLISH" : (context.structure.trend == 2 ? "BEARISH" : "NEUTRAL")));
      panel += StringFormat(" Liquidity Sweeps: SSL: %-3s | BSL: %-3s\n",
                            (context.liquidity.sellSideSweepActive ? "YES" : "NO"),
                            (context.liquidity.buySideSweepActive ? "YES" : "NO"));
      panel += StringFormat(" Order Blocks:     Bullish: %d | Bearish: %d\n", context.orderBlocks.activeBullishObCount, context.orderBlocks.activeBearishObCount);
      panel += StringFormat(" Fair Value Gaps:  Bullish: %d | Bearish: %d\n", context.fairValueGaps.unfilledBullishFvgCount, context.fairValueGaps.unfilledBearishFvgCount);
      panel += StringFormat(" Volume Status:    Strength: %.2f (Buy: %.2f / Sell: %.2f)\n",
                            context.features.volumeStrength.normalizedValue,
                            context.features.buyingPressure.normalizedValue,
                            context.features.sellingPressure.normalizedValue);
      panel += StringFormat(" Confluence Score: %.3f (Align: %.2f, Conflict: %.2f)\n",
                            context.confluence.overallConfluenceScore,
                            context.confluence.alignmentScore,
                            context.confluence.conflictScore);
      panel += StringFormat(" Decision Score:   %.3f (Confidence: %.2f)\n",
                            context.decisions.compositeScore,
                            context.decisions.confidence);
      panel += "------------------------------------------------------\n";
      panel += " PERFORMANCE & RENDERING TELEMETRY:\n";
      panel += StringFormat(" Tick Latency:     %.2f ms | Framework FPS: %.1f FPS\n", perf.tickProcessingMs, perf.currentFps);
      panel += StringFormat(" Chart Objects:    %d active / %d pool size\n", visSnap.totalActiveObjects, visSnap.poolSize);
      panel += StringFormat(" Memory Overhead:  <%d KB (Heap Zero-Alloc Guarantee)\n", perf.memoryUsageKb);
      panel += "======================================================\n";
      return panel;
   }
};
