//+------------------------------------------------------------------+
//|                                           Phase15DemoTest.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Engines/Confluence/ConfluenceEngine.mqh"
#include "../Framework/Decisions/DecisionSnapshot.mqh"

/// @class CPhase15DemoTest
/// @brief Framework demonstration: MarketContext -> ConfluenceEngine -> ConfluenceSnapshot -> Decision Framework.
class CPhase15DemoTest
{
public:
   static void RunDemo()
   {
      Print("======================================================================");
      Print("   PROJECT SENTINEL - PHASE 15 CONFLUENCE ENGINE DEMONSTRATION");
      Print("======================================================================");

      // 1. Initialize Market Context with analytical evidence inputs
      SMarketContext context;
      context.Reset();
      context.contextId = 1001;
      context.timestamp = TimeCurrent();

      // Setup Analytical Components
      context.structure.trend = 1;                              // Bullish Market Structure
      context.liquidity.sellSideSweepActive = true;            // Bullish Liquidity Sweep
      context.orderBlocks.activeBullishObCount = 2;            // Active Bullish OBs
      context.fairValueGaps.unfilledBullishFvgCount = 2;       // Active Bullish FVGs
      context.session.directionalBias = 0.5;                   // Bullish Session Bias
      context.state.stateType = 1;                              // Bullish Trending Regime
      context.features.buyingPressure.normalizedValue = 0.8;   // High Buying Volume
      context.features.sellingPressure.normalizedValue = 0.2;  
      context.orderFlow.delta = 0.45;                           // Positive Cumulative Delta

      Print("[INPUT] Aggregating Analytical Evidence across 8 Modules...");
      Print("  - Market Structure: Bullish");
      Print("  - Liquidity: Sell-Side Sweep Active");
      Print("  - Order Blocks: 2 Active Bullish OBs");
      Print("  - FVG: 2 Unfilled Bullish Gaps");
      Print("  - Session: Bullish Bias (+0.50)");
      Print("  - Market State: Bullish Trending");
      Print("  - Volume: Buying Delta (0.80 vs 0.20)");
      Print("  - Order Flow: Net Aggressive Buying Delta (+0.45)");

      // 2. Instantiate and run ConfluenceEngine
      CConfluenceEngine engine;
      SConfluenceSnapshot confluenceSnap;

      if(engine.Evaluate(context, confluenceSnap))
      {
         Print("----------------------------------------------------------------------");
         Print("[OUTPUT] ConfluenceEngine Execution Complete:");
         Print(StringFormat("  - Snapshot ID:             %d", confluenceSnap.snapshotId));
         Print(StringFormat("  - Net Bias:               %s", (confluenceSnap.netBias == BIAS_BULLISH ? "BULLISH" : (confluenceSnap.netBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL"))));
         Print(StringFormat("  - Overall Confluence Score: %.3f (-1.0 to +1.0)", confluenceSnap.overallConfluenceScore));
         Print(StringFormat("  - Alignment Score:          %.3f (0.0 to 1.0)", confluenceSnap.alignmentScore));
         Print(StringFormat("  - Conflict Score:           %.3f (0.0 to 1.0)", confluenceSnap.conflictScore));
         Print(StringFormat("  - Supporting Factors:       %d / %d", confluenceSnap.supportingFactors, confluenceSnap.evidenceCount));
         Print(StringFormat("  - Conflicting Factors:      %d", confluenceSnap.conflictingFactors));
         Print(StringFormat("  - Confluence Strength:      %d (0=None, 1=Weak, 2=Moderate, 3=Strong, 4=Extreme)", (int)confluenceSnap.strengthCategory));

         // 3. Attach ConfluenceSnapshot to MarketContext
         context.confluence = confluenceSnap;

         // 4. Pass MarketContext (containing ConfluenceSnapshot) to Decision Framework (Read-Only)
         SDecisionSnapshot decisionSnap;
         decisionSnap.Reset();
         decisionSnap.snapshotId = 5001;
         decisionSnap.confidence = confluenceSnap.alignmentScore * confluenceSnap.confidence;
         decisionSnap.timestamp  = confluenceSnap.timestamp;

         Print("----------------------------------------------------------------------");
         Print("[DOWNSTREAM] Decision Framework Consuming ConfluenceSnapshot:");
         Print(StringFormat("  - Decision Confidence derived from Confluence Alignment: %.3f", decisionSnap.confidence));
         Print("  - Note: Confluence Engine produced ZERO buy/sell recommendations or execution signals.");
      }
      else
      {
         Print("[ERROR] ConfluenceEngine evaluation failed!");
      }

      Print("======================================================================");
   }
};
