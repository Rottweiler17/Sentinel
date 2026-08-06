//+------------------------------------------------------------------+
//|                                                 ICTChecklist.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "ICTValidationTypes.mqh"

/// @class CICTChecklist
/// @brief Evaluates 8 individual core ICT conditions against input MarketContext snapshots.
class CICTChecklist
{
public:
   /// @brief Evaluates all 8 ICT conditions and populates conditions array.
   static void EvaluateChecklist(const SMarketContext &context, SICTConditionResult &conditions[])
   {
      // 1. Market Structure Shift (MSS / BOS)
      conditions[(int)ICT_COND_MARKET_STRUCTURE_SHIFT].condition = ICT_COND_MARKET_STRUCTURE_SHIFT;
      conditions[(int)ICT_COND_MARKET_STRUCTURE_SHIFT].weight    = 1.0;
      if(context.structure.trend != 0)
      {
         conditions[(int)ICT_COND_MARKET_STRUCTURE_SHIFT].satisfied   = true;
         conditions[(int)ICT_COND_MARKET_STRUCTURE_SHIFT].score       = 1.0;
         conditions[(int)ICT_COND_MARKET_STRUCTURE_SHIFT].description = "Market Structure Shift / Clear Trend Established";
      }
      else
      {
         conditions[(int)ICT_COND_MARKET_STRUCTURE_SHIFT].satisfied   = false;
         conditions[(int)ICT_COND_MARKET_STRUCTURE_SHIFT].score       = 0.0;
         conditions[(int)ICT_COND_MARKET_STRUCTURE_SHIFT].description = "Missing: Neutral Structure / No MSS";
      }

      // 2. Liquidity Sweep Present (BSL / SSL)
      conditions[(int)ICT_COND_LIQUIDITY_SWEEP].condition = ICT_COND_LIQUIDITY_SWEEP;
      conditions[(int)ICT_COND_LIQUIDITY_SWEEP].weight    = 0.95;
      if(context.liquidity.sellSideSweepActive || context.liquidity.buySideSweepActive)
      {
         conditions[(int)ICT_COND_LIQUIDITY_SWEEP].satisfied   = true;
         conditions[(int)ICT_COND_LIQUIDITY_SWEEP].score       = 0.95;
         conditions[(int)ICT_COND_LIQUIDITY_SWEEP].description = StringFormat("Liquidity Sweep Present (%s)", 
                                                                    (context.liquidity.sellSideSweepActive ? "SSL Sweep" : "BSL Sweep"));
      }
      else
      {
         conditions[(int)ICT_COND_LIQUIDITY_SWEEP].satisfied   = false;
         conditions[(int)ICT_COND_LIQUIDITY_SWEEP].score       = 0.0;
         conditions[(int)ICT_COND_LIQUIDITY_SWEEP].description = "Missing: No Active Liquidity Sweep";
      }

      // 3. Order Block Present (PDARRAY)
      conditions[(int)ICT_COND_ORDER_BLOCK_PRESENT].condition = ICT_COND_ORDER_BLOCK_PRESENT;
      conditions[(int)ICT_COND_ORDER_BLOCK_PRESENT].weight    = 0.90;
      int totalOB = context.orderBlocks.activeBullishObCount + context.orderBlocks.activeBearishObCount;
      if(totalOB > 0)
      {
         conditions[(int)ICT_COND_ORDER_BLOCK_PRESENT].satisfied   = true;
         conditions[(int)ICT_COND_ORDER_BLOCK_PRESENT].score       = 0.90;
         conditions[(int)ICT_COND_ORDER_BLOCK_PRESENT].description = StringFormat("Active Order Block Present (%d OBs)", totalOB);
      }
      else
      {
         conditions[(int)ICT_COND_ORDER_BLOCK_PRESENT].satisfied   = false;
         conditions[(int)ICT_COND_ORDER_BLOCK_PRESENT].score       = 0.0;
         conditions[(int)ICT_COND_ORDER_BLOCK_PRESENT].description = "Missing: No Active Order Block";
      }

      // 4. Fair Value Gap Present (PDARRAY)
      conditions[(int)ICT_COND_FVG_PRESENT].condition = ICT_COND_FVG_PRESENT;
      conditions[(int)ICT_COND_FVG_PRESENT].weight    = 0.85;
      int totalFVG = context.fairValueGaps.unfilledBullishFvgCount + context.fairValueGaps.unfilledBearishFvgCount;
      if(totalFVG > 0)
      {
         conditions[(int)ICT_COND_FVG_PRESENT].satisfied   = true;
         conditions[(int)ICT_COND_FVG_PRESENT].score       = 0.85;
         conditions[(int)ICT_COND_FVG_PRESENT].description = StringFormat("Unfilled Fair Value Gap Present (%d FVGs)", totalFVG);
      }
      else
      {
         conditions[(int)ICT_COND_FVG_PRESENT].satisfied   = false;
         conditions[(int)ICT_COND_FVG_PRESENT].score       = 0.0;
         conditions[(int)ICT_COND_FVG_PRESENT].description = "Missing: No Unfilled Fair Value Gap";
      }

      // 5. Session / Killzone Alignment
      conditions[(int)ICT_COND_KILLZONE_SESSION].condition = ICT_COND_KILLZONE_SESSION;
      conditions[(int)ICT_COND_KILLZONE_SESSION].weight    = 0.80;
      if(context.session.sessionType == 2 || context.session.sessionType == 3 || MathAbs(context.session.directionalBias) > 0.1)
      {
         conditions[(int)ICT_COND_KILLZONE_SESSION].satisfied   = true;
         conditions[(int)ICT_COND_KILLZONE_SESSION].score       = 0.80;
         conditions[(int)ICT_COND_KILLZONE_SESSION].description = "Active Killzone / High Volatility Session";
      }
      else
      {
         conditions[(int)ICT_COND_KILLZONE_SESSION].satisfied   = false;
         conditions[(int)ICT_COND_KILLZONE_SESSION].score       = 0.0;
         conditions[(int)ICT_COND_KILLZONE_SESSION].description = "Missing: Outside Major Killzone Window";
      }

      // 6. Market State Alignment
      conditions[(int)ICT_COND_MARKET_STATE].condition = ICT_COND_MARKET_STATE;
      conditions[(int)ICT_COND_MARKET_STATE].weight    = 0.75;
      if(context.state.stateType == 1 || context.state.stateType == 2)
      {
         conditions[(int)ICT_COND_MARKET_STATE].satisfied   = true;
         conditions[(int)ICT_COND_MARKET_STATE].score       = 0.75;
         conditions[(int)ICT_COND_MARKET_STATE].description = "Market State: Active Expansion / Trending Regime";
      }
      else
      {
         conditions[(int)ICT_COND_MARKET_STATE].satisfied   = false;
         conditions[(int)ICT_COND_MARKET_STATE].score       = 0.0;
         conditions[(int)ICT_COND_MARKET_STATE].description = "Missing: Consolidation / Choppy Market State";
      }

      // 7. Confluence Alignment
      conditions[(int)ICT_COND_CONFLUENCE_SCORE].condition = ICT_COND_CONFLUENCE_SCORE;
      conditions[(int)ICT_COND_CONFLUENCE_SCORE].weight    = 0.90;
      if(MathAbs(context.confluence.overallConfluenceScore) >= 0.50 && context.confluence.alignmentScore >= 0.50)
      {
         conditions[(int)ICT_COND_CONFLUENCE_SCORE].satisfied   = true;
         conditions[(int)ICT_COND_CONFLUENCE_SCORE].score       = context.confluence.alignmentScore;
         conditions[(int)ICT_COND_CONFLUENCE_SCORE].description = StringFormat("Confluence Alignment Satisfied (Score: %.2f)", context.confluence.overallConfluenceScore);
      }
      else
      {
         conditions[(int)ICT_COND_CONFLUENCE_SCORE].satisfied   = false;
         conditions[(int)ICT_COND_CONFLUENCE_SCORE].score       = 0.0;
         conditions[(int)ICT_COND_CONFLUENCE_SCORE].description = StringFormat("Missing: Weak Confluence (Score: %.2f)", context.confluence.overallConfluenceScore);
      }

      // 8. Decision Framework Score
      conditions[(int)ICT_COND_DECISION_SCORE].condition = ICT_COND_DECISION_SCORE;
      conditions[(int)ICT_COND_DECISION_SCORE].weight    = 0.85;
      if(MathAbs(context.decisions.compositeScore) >= 0.50 || context.decisions.confidence >= 0.50)
      {
         conditions[(int)ICT_COND_DECISION_SCORE].satisfied   = true;
         conditions[(int)ICT_COND_DECISION_SCORE].score       = context.decisions.confidence;
         conditions[(int)ICT_COND_DECISION_SCORE].description = StringFormat("Decision Framework Alignment (Score: %.2f)", context.decisions.compositeScore);
      }
      else
      {
         conditions[(int)ICT_COND_DECISION_SCORE].satisfied   = false;
         conditions[(int)ICT_COND_DECISION_SCORE].score       = 0.0;
         conditions[(int)ICT_COND_DECISION_SCORE].description = "Missing: Low Decision Confidence";
      }
   }
};
