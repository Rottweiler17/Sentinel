//+------------------------------------------------------------------+
//|                                          EvidenceAggregator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "ConfluenceTypes.mqh"
#include "ConfluenceConfiguration.mqh"

/// @class CEvidenceAggregator
/// @brief Standardizes and extracts evidence factors across all 8 supported analytical modules.
class CEvidenceAggregator
{
public:
   /// @brief Aggregates evidence factors from MarketContext and FeatureSnapshot into evidenceList.
   static int AggregateEvidence(const SMarketContext &context,
                                const SConfluenceConfiguration &config,
                                SEvidenceFactor &evidenceList[])
   {
      int activeCount = 0;

      // 1. Market Structure
      if(config.enableStructure)
      {
         SEvidenceFactor factor;
         factor.Reset();
         factor.source = EVIDENCE_MARKET_STRUCTURE;
         factor.weight = config.structureWeight;

         if(context.structure.externalTrend == TREND_BULLISH)
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 1.0;
            factor.description = "Market Structure: External Bullish Trend";
         }
         else if(context.structure.externalTrend == TREND_BEARISH)
         {
            factor.bias        = BIAS_BEARISH;
            factor.score       = -1.0;
            factor.description = "Market Structure: External Bearish Trend";
         }
         else
         {
            factor.bias        = BIAS_NEUTRAL;
            factor.score       = 0.0;
            factor.description = "Market Structure: Neutral / Ranging Structure";
         }

         factor.confidence = (context.features.structureScore.confidence > 0.0) ? 
                              context.features.structureScore.confidence : 0.85;
         evidenceList[(int)EVIDENCE_MARKET_STRUCTURE] = factor;
         if(factor.bias != BIAS_NEUTRAL) activeCount++;
      }

      // 2. Liquidity
      if(config.enableLiquidity)
      {
         SEvidenceFactor factor;
         factor.Reset();
         factor.source = EVIDENCE_LIQUIDITY;
         factor.weight = config.liquidityWeight;

         if(context.liquidity.sweepDirection == SWEEP_BULLISH)
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 0.9;
            factor.description = "Liquidity: Bullish Liquidity Sweep Reaction";
         }
         else if(context.liquidity.sweepDirection == SWEEP_BEARISH)
         {
            factor.bias        = BIAS_BEARISH;
            factor.score       = -0.9;
            factor.description = "Liquidity: Bearish Liquidity Sweep Reaction";
         }
         else
         {
            factor.bias        = BIAS_NEUTRAL;
            factor.score       = 0.0;
            factor.description = "Liquidity: No Active Sweep Detected";
         }

         factor.confidence = (context.features.liquidityScore.confidence > 0.0) ?
                              context.features.liquidityScore.confidence : 0.80;
         evidenceList[(int)EVIDENCE_LIQUIDITY] = factor;
         if(factor.bias != BIAS_NEUTRAL) activeCount++;
      }

      // 3. Order Blocks
      if(config.enableOrderBlocks)
      {
         SEvidenceFactor factor;
         factor.Reset();
         factor.source = EVIDENCE_ORDER_BLOCK;
         factor.weight = config.orderBlockWeight;

         int bullishOB = 0, bearishOB = 0;
         for(int i = 0; i < context.orderBlocks.activeBlocksCount; i++)
         {
            if(context.orderBlocks.activeBlocks[i].direction == ORDERBLOCK_BULLISH)
               bullishOB++;
            else if(context.orderBlocks.activeBlocks[i].direction == ORDERBLOCK_BEARISH)
               bearishOB++;
         }

         if(bullishOB > bearishOB)
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 0.85;
            factor.description = StringFormat("Order Blocks: Active Bullish OB Dominance (%d vs %d)", bullishOB, bearishOB);
         }
         else if(bearishOB > bullishOB)
         {
            factor.bias        = BIAS_BEARISH;
            factor.score       = -0.85;
            factor.description = StringFormat("Order Blocks: Active Bearish OB Dominance (%d vs %d)", bearishOB, bullishOB);
         }
         else
         {
            factor.bias        = BIAS_NEUTRAL;
            factor.score       = 0.0;
            factor.description = "Order Blocks: Balanced Bullish/Bearish OBs";
         }

         factor.confidence = 0.82;
         evidenceList[(int)EVIDENCE_ORDER_BLOCK] = factor;
         if(factor.bias != BIAS_NEUTRAL) activeCount++;
      }

      // 4. Fair Value Gaps (FVG)
      if(config.enableFVG)
      {
         SEvidenceFactor factor;
         factor.Reset();
         factor.source = EVIDENCE_FVG;
         factor.weight = config.fvgWeight;

         int bullishFVG = 0, bearishFVG = 0;
         for(int i = 0; i < context.fairValueGaps.activeGapsCount; i++)
         {
            if(context.fairValueGaps.activeGaps[i].direction == FVG_BULLISH && context.fairValueGaps.activeGaps[i].fillPercentage < 100.0)
               bullishFVG++;
            else if(context.fairValueGaps.activeGaps[i].direction == FVG_BEARISH && context.fairValueGaps.activeGaps[i].fillPercentage < 100.0)
               bearishFVG++;
         }

         if(bullishFVG > bearishFVG)
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 0.80;
            factor.description = StringFormat("FVG: Bullish Imbalance Dominance (%d unfilled)", bullishFVG);
         }
         else if(bearishFVG > bullishFVG)
         {
            factor.bias        = BIAS_BEARISH;
            factor.score       = -0.80;
            factor.description = StringFormat("FVG: Bearish Imbalance Dominance (%d unfilled)", bearishFVG);
         }
         else
         {
            factor.bias        = BIAS_NEUTRAL;
            factor.score       = 0.0;
            factor.description = "FVG: Balanced Fair Value Gap State";
         }

         factor.confidence = 0.78;
         evidenceList[(int)EVIDENCE_FVG] = factor;
         if(factor.bias != BIAS_NEUTRAL) activeCount++;
      }

      // 5. Session
      if(config.enableSession)
      {
         SEvidenceFactor factor;
         factor.Reset();
         factor.source = EVIDENCE_SESSION;
         factor.weight = config.sessionWeight;

         if(context.session.currentSession == SESSION_MKT_LONDON || context.session.currentSession == SESSION_MKT_NEWYORK)
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 0.6;
            factor.description = "Session: Active Major Killzone Session";
         }
         else
         {
            factor.bias        = BIAS_NEUTRAL;
            factor.score       = 0.0;
            factor.description = "Session: Neutral Session State";
         }

         factor.confidence = (context.features.sessionWeight.confidence > 0.0) ? 
                              context.features.sessionWeight.confidence : 0.75;
         evidenceList[(int)EVIDENCE_SESSION] = factor;
         if(factor.bias != BIAS_NEUTRAL) activeCount++;
      }

      // 6. Market State
      if(config.enableMarketState)
      {
         SEvidenceFactor factor;
         factor.Reset();
         factor.source = EVIDENCE_MARKET_STATE;
         factor.weight = config.stateWeight;

         if(context.state.currentState == STATE_ENV_TRENDING_BULLISH || context.state.currentState == STATE_ENV_EXPANSION)
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 0.85;
            factor.description = "Market State: Bullish Trending/Expansion Regime";
         }
         else if(context.state.currentState == STATE_ENV_TRENDING_BEARISH)
         {
            factor.bias        = BIAS_BEARISH;
            factor.score       = -0.85;
            factor.description = "Market State: Bearish Trending Regime";
         }
         else
         {
            factor.bias        = BIAS_NEUTRAL;
            factor.score       = 0.0;
            factor.description = "Market State: Ranging / Consolidation Regime";
         }

         factor.confidence = (context.features.marketStateScore.confidence > 0.0) ? 
                              context.features.marketStateScore.confidence : 0.80;
         evidenceList[(int)EVIDENCE_MARKET_STATE] = factor;
         if(factor.bias != BIAS_NEUTRAL) activeCount++;
      }

      // 7. Volume
      if(config.enableVolume)
      {
         SEvidenceFactor factor;
         factor.Reset();
         factor.source = EVIDENCE_VOLUME;
         factor.weight = config.volumeWeight;

         if(context.volume.relativeVolume > 1.2)
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 0.75;
            factor.description = "Volume: High Relative Volume Expansion";
         }
         else
         {
            factor.bias        = BIAS_NEUTRAL;
            factor.score       = 0.0;
            factor.description = "Volume: Normal Volume Activity";
         }

         factor.confidence = (context.features.volumeStrength.confidence > 0.0) ? 
                              context.features.volumeStrength.confidence : 0.70;
         evidenceList[(int)EVIDENCE_VOLUME] = factor;
         if(factor.bias != BIAS_NEUTRAL) activeCount++;
      }

      // 8. Order Flow Approximation
      if(config.enableOrderFlow)
      {
         SEvidenceFactor factor;
         factor.Reset();
         factor.source = EVIDENCE_ORDER_FLOW;
         factor.weight = config.orderFlowWeight;

         if(context.orderFlow.buyingPressure > context.orderFlow.sellingPressure + 10.0)
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 0.80;
            factor.description = "Order Flow: Dominant Buying Pressure";
         }
         else if(context.orderFlow.sellingPressure > context.orderFlow.buyingPressure + 10.0)
         {
            factor.bias        = BIAS_BEARISH;
            factor.score       = -0.80;
            factor.description = "Order Flow: Dominant Selling Pressure";
         }
         else
         {
            factor.bias        = BIAS_NEUTRAL;
            factor.score       = 0.0;
            factor.description = "Order Flow: Balanced Pressure";
         }

         factor.confidence = 0.75;
         evidenceList[(int)EVIDENCE_ORDER_FLOW] = factor;
         if(factor.bias != BIAS_NEUTRAL) activeCount++;
      }

      return activeCount;
   }
};
