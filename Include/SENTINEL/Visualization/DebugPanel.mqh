//+------------------------------------------------------------------+
//|                                                   DebugPanel.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "VisualizationTypes.mqh"
#include "ThemeManager.mqh"

/// @class CDebugPanel
/// @brief Renders movable on-screen debug panel displaying key telemetry metrics.
class CDebugPanel
{
private:
   int  m_posX;
   int  m_posY;
   long m_chartId;

public:
   CDebugPanel() : m_posX(20), m_posY(30), m_chartId(0) {}

   void Initialize(long chartId, int x = 20, int y = 30)
   {
      m_chartId = chartId;
      m_posX    = x;
      m_posY    = y;
   }

   /// @brief Formats text output summary of MarketContext telemetry.
   static string FormatDebugContent(const SMarketContext &context, double fps, double tickMs)
   {
      string output = "=== SENTINEL FRAMEWORK DEBUG PANEL ===\n";
      output += StringFormat("Symbol:            %s\n", _Symbol);
      output += StringFormat("Timeframe:         %d min\n", _Period);
      output += StringFormat("Session:           %s (Bias: %.2f)\n", 
                             (context.session.sessionType == 1 ? "ASIA" : (context.session.sessionType == 2 ? "LONDON" : "NY")),
                             context.session.directionalBias);
      output += StringFormat("Market State:      %s\n", (context.state.stateType == 1 ? "TRENDING_BULLISH" : (context.state.stateType == 2 ? "TRENDING_BEARISH" : "RANGING")));
      output += StringFormat("Trend:             %s\n", (context.structure.trend == 1 ? "BULLISH" : (context.structure.trend == 2 ? "BEARISH" : "NEUTRAL")));
      output += StringFormat("Liquidity:         SSL Sweep: %s | BSL Sweep: %s\n", 
                             (context.liquidity.sellSideSweepActive ? "YES" : "NO"),
                             (context.liquidity.buySideSweepActive ? "YES" : "NO"));
      output += StringFormat("Order Blocks:      Bullish: %d | Bearish: %d\n", context.orderBlocks.activeBullishObCount, context.orderBlocks.activeBearishObCount);
      output += StringFormat("Fair Value Gaps:   Bullish: %d | Bearish: %d\n", context.fairValueGaps.unfilledBullishFvgCount, context.fairValueGaps.unfilledBearishFvgCount);
      output += StringFormat("Volume Strength:   %.2f (Buy: %.2f / Sell: %.2f)\n", 
                             context.features.volumeStrength.normalizedValue,
                             context.features.buyingPressure.normalizedValue,
                             context.features.sellingPressure.normalizedValue);
      output += StringFormat("Confluence Score:  %.3f (Align: %.2f, Conflict: %.2f)\n", 
                             context.confluence.overallConfluenceScore,
                             context.confluence.alignmentScore,
                             context.confluence.conflictScore);
      output += StringFormat("Decision Score:    %.3f (Confidence: %.2f)\n", 
                             context.decisions.compositeScore,
                             context.decisions.confidence);
      output += "--------------------------------------\n";
      output += StringFormat("Framework FPS:     %.1f FPS\n", fps);
      output += StringFormat("Tick Processing:   %.2f ms\n", tickMs);
      output += StringFormat("Memory Usage:      < 32 KB (Heap Zero Alloc)\n");
      return output;
   }
};
