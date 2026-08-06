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
      if(context.structure.externalTrend != TREND_NEUTRAL && context.structure.externalTrend != TREND_UNKNOWN)
      {
         conditions[(int)ICT_COND_MARKET_STRUCTURE_SHIFT].satisfied   = true;
         conditions[(int)ICT_COND_MARKET_STRUCTURE_SHIFT].score       = 1.0;
         conditions[(int)ICT_COND_MARKET_STRUCTURE_SHIFT].description = "Market Structure Shift / Clear External Trend Established";
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
      if(context.liquidity.sweepDirection != SWEEP_NONE)
      {
         conditions[(int)ICT_COND_LIQUIDITY_SWEEP].satisfied   = true;
         conditions[(int)ICT_COND_LIQUIDITY_SWEEP].score       = 0.95;
         conditions[(int)ICT_COND_LIQUIDITY_SWEEP].description = StringFormat("Liquidity Sweep Present (Sweep Direction #%d)", (int)context.liquidity.sweepDirection);
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
      if(context.orderBlocks.activeBlocksCount > 0)
      {
         conditions[(int)ICT_COND_ORDER_BLOCK_PRESENT].satisfied   = true;
         conditions[(int)ICT_COND_ORDER_BLOCK_PRESENT].score       = 0.90;
         conditions[(int)ICT_COND_ORDER_BLOCK_PRESENT].description = StringFormat("Active Order Block Present (%d OBs)", context.orderBlocks.activeBlocksCount);
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
      if(context.fairValueGaps.activeGapsCount > 0)
      {
         conditions[(int)ICT_COND_FVG_PRESENT].satisfied   = true;
         conditions[(int)ICT_COND_FVG_PRESENT].score       = 0.85;
         conditions[(int)ICT_COND_FVG_PRESENT].description = StringFormat("Active Fair Value Gap Present (%d FVGs)", context.fairValueGaps.activeGapsCount);
      }
      else
      {
         conditions[(int)ICT_COND_FVG_PRESENT].satisfied   = false;
         conditions[(int)ICT_COND_FVG_PRESENT].score       = 0.0;
         conditions[(int)ICT_COND_FVG_PRESENT].description = "Missing: No Active Fair Value Gap";
      }

      // 5. Session / Killzone Alignment
      conditions[(int)ICT_COND_KILLZONE_SESSION].condition = ICT_COND_KILLZONE_SESSION;
      conditions[(int)ICT_COND_KILLZONE_SESSION].weight    = 0.80;
      if(context.session.currentSession == SESSION_MKT_LONDON || context.session.currentSession == SESSION_MKT_NEWYORK)
      {
         conditions[(int)ICT_COND_KILLZONE_SESSION].satisfied   = true;
         conditions[(int)ICT_COND_KILLZONE_SESSION].score       = 0.80;
         conditions[(int)ICT_COND_KILLZONE_SESSION].description = "Active Major Session Killzone";
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
      if(context.state.currentState == STATE_ENV_TRENDING_BULLISH || context.state.currentState == STATE_ENV_TRENDING_BEARISH || context.state.currentState == STATE_ENV_EXPANSION)
      {
         conditions[(int)ICT_COND_MARKET_STATE].satisfied   = true;
         conditions[(int)ICT_COND_MARKET_STATE].score       = 0.75;
         conditions[(int)ICT_COND_MARKET_STATE].description = "Market State: Active Expansion / Trending Regime";
      }
      else
      {
         conditions[(int)ICT_COND_MARKET_STATE].satisfied   = false;
         conditions[(int)ICT_COND_MARKET_STATE].score       = 0.0;
         conditions[(int)ICT_COND_MARKET_STATE].description = "Missing: Ranging / Consolidation Market State";
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
      if(MathAbs(context.decisions.overallScore) >= 0.50 || context.decisions.confidence >= 0.50)
      {
         conditions[(int)ICT_COND_DECISION_SCORE].satisfied   = true;
         conditions[(int)ICT_COND_DECISION_SCORE].score       = context.decisions.confidence;
         conditions[(int)ICT_COND_DECISION_SCORE].description = StringFormat("Decision Framework Alignment (Score: %.2f)", context.decisions.overallScore);
      }
      else
      {
         conditions[(int)ICT_COND_DECISION_SCORE].satisfied   = false;
         conditions[(int)ICT_COND_DECISION_SCORE].score       = 0.0;
         conditions[(int)ICT_COND_DECISION_SCORE].description = "Missing: Low Decision Score";
      }
   }
};
