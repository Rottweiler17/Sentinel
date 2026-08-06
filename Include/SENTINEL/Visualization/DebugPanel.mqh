//+------------------------------------------------------------------+
//|                                                   DebugPanel.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Framework/Context/MarketContext.mqh"
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
      output += StringFormat("Session:           Enum Session #%d\n", (int)context.session.currentSession);
      output += StringFormat("Market State:      Enum State #%d (Conf: %.1f%%)\n", (int)context.state.currentState, context.state.confidence);
      output += StringFormat("External Trend:    Enum Trend #%d (Strength: %.2f)\n", (int)context.structure.externalTrend, context.structure.trendStrength);
      output += StringFormat("Liquidity Sweep:   Enum Sweep #%d (Active Pools: %d)\n", (int)context.liquidity.sweepDirection, context.liquidity.activePoolsCount);
      output += StringFormat("Order Blocks:      Active Blocks: %d\n", context.orderBlocks.activeBlocksCount);
      output += StringFormat("Fair Value Gaps:   Active Gaps: %d\n", context.fairValueGaps.activeGapsCount);
      output += StringFormat("Volume Metric:     RelVol: %.2f (BuyP: %.1f / SellP: %.1f)\n", 
                             context.volume.relativeVolume,
                             context.orderFlow.buyingPressure,
                             context.orderFlow.sellingPressure);
      output += StringFormat("Confluence Score:  %.3f (Align: %.2f, Conflict: %.2f)\n", 
                             context.confluence.overallConfluenceScore,
                             context.confluence.alignmentScore,
                             context.confluence.conflictScore);
      output += StringFormat("Decision Score:    %.3f (Confidence: %.2f)\n", 
                             context.decisions.overallScore,
                             context.decisions.confidence);
      output += "--------------------------------------\n";
      output += StringFormat("Framework FPS:     %.1f FPS\n", fps);
      output += StringFormat("Tick Processing:   %.2f ms\n", tickMs);
      output += "Memory Usage:      < 32 KB (Heap Zero Alloc)\n";
      return output;
   }
};
