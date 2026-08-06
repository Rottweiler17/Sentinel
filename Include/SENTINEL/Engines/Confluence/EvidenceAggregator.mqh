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

         // Determine bias from structure snapshot trend enum or feature score
         if(context.structure.trend == 1) // Bullish
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 1.0;
            factor.description = "Market Structure: Bullish Trend / Higher Highs";
         }
         else if(context.structure.trend == 2) // Bearish
         {
            factor.bias        = BIAS_BEARISH;
            factor.score       = -1.0;
            factor.description = "Market Structure: Bearish Trend / Lower Lows";
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

         if(context.liquidity.sellSideSweepActive)
         {
            factor.bias        = BIAS_BULLISH; // SSL sweep -> bullish reversal setup
            factor.score       = 0.9;
            factor.description = "Liquidity: Sell-Side Liquidity Swept (Bullish Reaction)";
         }
         else if(context.liquidity.buySideSweepActive)
         {
            factor.bias        = BIAS_BEARISH; // BSL sweep -> bearish reversal setup
            factor.score       = -0.9;
            factor.description = "Liquidity: Buy-Side Liquidity Swept (Bearish Reaction)";
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

         if(context.orderBlocks.activeBullishObCount > context.orderBlocks.activeBearishObCount)
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 0.85;
            factor.description = StringFormat("Order Blocks: Active Bullish OB Dominance (%d vs %d)", 
                                             context.orderBlocks.activeBullishObCount, context.orderBlocks.activeBearishObCount);
         }
         else if(context.orderBlocks.activeBearishObCount > context.orderBlocks.activeBullishObCount)
         {
            factor.bias        = BIAS_BEARISH;
            factor.score       = -0.85;
            factor.description = StringFormat("Order Blocks: Active Bearish OB Dominance (%d vs %d)", 
                                             context.orderBlocks.activeBearishObCount, context.orderBlocks.activeBullishObCount);
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

         if(context.fairValueGaps.unfilledBullishFvgCount > context.fairValueGaps.unfilledBearishFvgCount)
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 0.80;
            factor.description = StringFormat("FVG: Bullish Imbalance Dominance (%d unfilled)", 
                                             context.fairValueGaps.unfilledBullishFvgCount);
         }
         else if(context.fairValueGaps.unfilledBearishFvgCount > context.fairValueGaps.unfilledBullishFvgCount)
         {
            factor.bias        = BIAS_BEARISH;
            factor.score       = -0.80;
            factor.description = StringFormat("FVG: Bearish Imbalance Dominance (%d unfilled)", 
                                             context.fairValueGaps.unfilledBearishFvgCount);
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

         if(context.session.directionalBias > 0.1)
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = context.session.directionalBias;
            factor.description = "Session: Bullish Session Expansion Bias";
         }
         else if(context.session.directionalBias < -0.1)
         {
            factor.bias        = BIAS_BEARISH;
            factor.score       = context.session.directionalBias;
            factor.description = "Session: Bearish Session Expansion Bias";
         }
         else
         {
            factor.bias        = BIAS_NEUTRAL;
            factor.score       = 0.0;
            factor.description = "Session: Neutral Session Volatility";
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

         if(context.state.stateType == 1) // TRENDING_BULLISH
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 0.85;
            factor.description = "Market State: Bullish Trending Regime";
         }
         else if(context.state.stateType == 2) // TRENDING_BEARISH
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

         double deltaVolume = context.features.buyingPressure.normalizedValue - context.features.sellingPressure.normalizedValue;
         if(deltaVolume > 0.15)
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 0.75;
            factor.description = "Volume: Dominant Buying Pressure";
         }
         else if(deltaVolume < -0.15)
         {
            factor.bias        = BIAS_BEARISH;
            factor.score       = -0.75;
            factor.description = "Volume: Dominant Selling Pressure";
         }
         else
         {
            factor.bias        = BIAS_NEUTRAL;
            factor.score       = 0.0;
            factor.description = "Volume: Neutral Buying/Selling Volume";
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

         if(context.orderFlow.delta > 0.1)
         {
            factor.bias        = BIAS_BULLISH;
            factor.score       = 0.80;
            factor.description = "Order Flow: Net Aggressive Buying Delta";
         }
         else if(context.orderFlow.delta < -0.1)
         {
            factor.bias        = BIAS_BEARISH;
            factor.score       = -0.80;
            factor.description = "Order Flow: Net Aggressive Selling Delta";
         }
         else
         {
            factor.bias        = BIAS_NEUTRAL;
            factor.score       = 0.0;
            factor.description = "Order Flow: Balanced Order Flow Imbalance";
         }

         factor.confidence = 0.75;
         evidenceList[(int)EVIDENCE_ORDER_FLOW] = factor;
         if(factor.bias != BIAS_NEUTRAL) activeCount++;
      }

      return activeCount;
   }
};
