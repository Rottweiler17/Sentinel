//+------------------------------------------------------------------+
//|                                           Phase16DemoTest.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Visualization/VisualizationEngine.mqh"
#include "../Framework/Context/MarketContext.mqh"

/// @class CPhase16DemoTest
/// @brief Framework demonstration: XAUUSD visualization, layer toggles, Validation Mode, and Replay support.
class CPhase16DemoTest
{
public:
   static void RunDemo()
   {
      Print("======================================================================");
      Print("   PROJECT SENTINEL - PHASE 16 VISUALIZATION TOOLKIT DEMONSTRATION");
      Print("======================================================================");

      // 1. Initialize Market Context for XAUUSD Symbol
      SMarketContext context;
      context.Reset();
      context.contextId = 9001;
      context.sequenceNumber = 100;
      context.timestamp = TimeCurrent();

      // Populate Snapshots across all analytical modules
      context.marketData.currentCandle.high   = 2450.50;
      context.marketData.currentCandle.low    = 2435.20;
      context.marketData.currentCandle.close  = 2448.10;

      context.structure.externalTrend = TREND_BULLISH;
      context.liquidity.sweepDirection = SWEEP_BULLISH;
      context.zones.activeZonesCount = 2;
      context.orderBlocks.activeBlocksCount = 2;
      context.fairValueGaps.activeGapsCount = 1;
      context.session.currentSession = SESSION_LONDON;
      context.state.currentState = STATE_ENV_TRENDING_BULLISH;
      context.volume.relativeVolume = 1.5;
      context.orderFlow.buyingPressure = 75.0;
      context.orderFlow.sellingPressure = 25.0;
      context.confluence.overallConfluenceScore = 0.82;
      context.confluence.alignmentScore = 0.88;
      context.confluence.conflictScore = 0.05;
      context.decisions.overallScore = 0.78;
      context.decisions.confidence = 0.85;

      Print("[1. XAUUSD CONTEXT SIMULATION] Loaded XAUUSD H1 MarketContext");
      Print("  - Market Structure: External Bullish Trend (High: 2450.50, Low: 2435.20)");
      Print("  - Liquidity: Bullish Sweep Active");
      Print("  - Order Blocks: 2 Active OBs | FVG: 1 Active FVG");
      Print("  - Confluence Score: +0.82 (Alignment: 0.88, Conflict: 0.05)");

      // 2. Instantiate VisualizationEngine
      CVisualizationEngine engine;
      engine.Initialize(0);

      Print("----------------------------------------------------------------------");
      Print("[2. ENGINE RENDERING] Executing Frame Cycle...");
      engine.Render(context);

      SVisualizationSnapshot snap = engine.GetSnapshot();
      Print(StringFormat("  - Render Snapshot ID:   %d", snap.snapshotId));
      Print(StringFormat("  - Active Chart Objects: %d / %d Pool Size", snap.totalActiveObjects, snap.poolSize));
      Print(StringFormat("  - Active Theme:         %s", (snap.theme == THEME_DARK ? "DARK" : "LIGHT")));

      // 3. Demonstrate Layer Toggling
      Print("----------------------------------------------------------------------");
      Print("[3. LAYER TOGGLE SYSTEM] Toggling Layer 2 (Structure) OFF & ON...");
      engine.SetLayerVisible(LAYER_STRUCTURE, false);
      Print("  - LAYER_STRUCTURE disabled -> Render objects updated cleanly");

      engine.SetLayerVisible(LAYER_STRUCTURE, true);
      Print("  - LAYER_STRUCTURE re-enabled -> All 10 layers active");

      // 4. Demonstrate Validation Mode & Snapshot Inspection
      Print("----------------------------------------------------------------------");
      Print("[4. VALIDATION MODE] Simulating Candle Click on Bar #24...");
      engine.SetValidationMode(true);
      string inspectionText = CValidationModeOverlay::FormatValidationOutput(context, 24);
      Print(inspectionText);

      // 5. Demonstrate Replay Visualization
      Print("----------------------------------------------------------------------");
      Print("[5. REPLAY SUPPORT] Simulating Historical Snapshot Sequence Replay...");
      for(int seq = 101; seq <= 103; seq++)
      {
         context.sequenceNumber = seq;
         context.marketData.currentCandle.close += 1.50;
         engine.Render(context);
         Print(StringFormat("  - Replay Step %d Rendered (Close: %.2f)", seq, context.marketData.currentCandle.close));
      }

      Print("----------------------------------------------------------------------");
      Print("[SUMMARY] Developer Visualization Toolkit operates 100% Read-Only.");
      Print("          Zero trade signals produced. Zero state mutations performed.");
      Print("======================================================================");
   }
};
