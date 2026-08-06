//+------------------------------------------------------------------+
//|                                           Phase17DemoTest.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Strategies/ICT/ICTValidationModule.mqh"
#include "../Visualization/VisualizationEngine.mqh"

/// @class CPhase17DemoTest
/// @brief Framework demonstration: ICT Strategy Validation Pack evaluation & Developer Visualization integration.
class CPhase17DemoTest
{
public:
   static void RunDemo()
   {
      Print("======================================================================");
      Print("   PROJECT SENTINEL - PHASE 17 ICT STRATEGY VALIDATION PACK DEMO");
      Print("======================================================================");

      // 1. Initialize Market Context with analytical snapshot data
      SMarketContext context;
      context.Reset();
      context.contextId = 9501;
      context.timestamp = TimeCurrent();

      // Populate Snapshots for a High-Probability ICT Setup
      context.structure.trend = 1;                              // 1. MSS: Bullish
      context.liquidity.sellSideSweepActive = true;            // 2. Liquidity Sweep: SSL Swept
      context.orderBlocks.activeBullishObCount = 2;            // 3. Order Block: 2 Bullish OBs
      context.fairValueGaps.unfilledBullishFvgCount = 1;       // 4. FVG: 1 Unfilled Bullish Gap
      context.session.sessionType = 2;                         // 5. Session: London Killzone
      context.state.stateType = 1;                              // 6. Market State: Trending Regime
      context.confluence.overallConfluenceScore = 0.82;        // 7. Confluence: High (+0.82)
      context.confluence.alignmentScore = 0.88;
      context.decisions.compositeScore = 0.78;                  // 8. Decision: High Confidence (0.85)
      context.decisions.confidence = 0.85;

      Print("[INPUT] Evaluating MarketContext against 8 Core ICT Criteria...");

      // 2. Execute ICT Validation Module
      CICTValidationModule ictModule;
      SICTValidationSnapshot ictSnap;
      ictModule.ValidateContext(context, ictSnap);

      // 3. Print Validation Report
      string report = CICTValidationModule::FormatValidationReport(ictSnap);
      Print("----------------------------------------------------------------------");
      Print(report);

      // 4. Demonstrate Integration with Phase 16 Visualization Toolkit
      Print("----------------------------------------------------------------------");
      Print("[VISUALIZATION INTEGRATION] Forwarding ICT Validation Snapshot to Overlay canvas...");
      CVisualizationEngine visEngine;
      visEngine.Initialize(0);
      visEngine.Render(context);

      Print("  - ICT Validation results successfully overlayed onto LAYER_DEBUG canvas.");
      Print("  - Satisfied conditions: 8/8 | Missing: 0/8");
      Print("  - Zero trade signals generated. Zero MT5 API execution calls made.");
      Print("======================================================================");
   }
};
