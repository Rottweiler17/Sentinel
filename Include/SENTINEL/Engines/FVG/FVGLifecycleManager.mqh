//+------------------------------------------------------------------+
//|                                           FVGLifecycleManager.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "FVGTypes.mqh"
#include "FVGConfiguration.mqh"

/// @class CFVGLifecycleManager
/// @brief Manages the live state tracking, partial fills, and completion fill conditions of FVGs.
class CFVGLifecycleManager
{
public:
   static void UpdateLifecycle(const SMarketContext &context, const CFVGConfiguration &config, SFairValueGap &gap)
   {
      if(gap.lifecycleState == FVG_STATE_COMPLETELY_FILLED || gap.lifecycleState == FVG_STATE_INVALIDATED)
         return;

      double curPrice = context.marketData.bid;

      // Initialize state to ACTIVE if newly created
      if(gap.lifecycleState == FVG_STATE_CREATED)
      {
         gap.lifecycleState = FVG_STATE_ACTIVE;
      }

      // Check retests & fills
      if(gap.direction == FVG_BULLISH)
      {
         // Price retraces down into the bullish FVG (demand imbalance)
         if(curPrice <= gap.upperPrice && curPrice >= gap.lowerPrice)
         {
            gap.touchCount++;
            double filledAmount = gap.upperPrice - curPrice;
            double fillPct = (gap.gapSize > 0.0) ? (filledAmount / gap.gapSize) * 100.0 : 0.0;
            
            gap.fillPercentage = MathMax(gap.fillPercentage, fillPct);
            
            if(gap.fillPercentage >= 99.0)
            {
               gap.lifecycleState = FVG_STATE_COMPLETELY_FILLED;
               gap.freshness = 0.0;
            }
            else if(gap.fillPercentage >= config.PartialFillRatio())
            {
               gap.lifecycleState = FVG_STATE_PARTIALLY_FILLED;
               gap.freshness *= 0.5;
            }
         }
         else if(curPrice < gap.lowerPrice) // Invalidated if price breaks completely below FVG base
         {
            gap.lifecycleState = FVG_STATE_COMPLETELY_FILLED;
            gap.fillPercentage = 100.0;
            gap.freshness = 0.0;
         }
      }
      else if(gap.direction == FVG_BEARISH)
      {
         // Price retraces up into the bearish FVG (supply imbalance)
         if(curPrice >= gap.lowerPrice && curPrice <= gap.upperPrice)
         {
            gap.touchCount++;
            double filledAmount = curPrice - gap.lowerPrice;
            double fillPct = (gap.gapSize > 0.0) ? (filledAmount / gap.gapSize) * 100.0 : 0.0;
            
            gap.fillPercentage = MathMax(gap.fillPercentage, fillPct);
            
            if(gap.fillPercentage >= 99.0)
            {
               gap.lifecycleState = FVG_STATE_COMPLETELY_FILLED;
               gap.freshness = 0.0;
            }
            else if(gap.fillPercentage >= config.PartialFillRatio())
            {
               gap.lifecycleState = FVG_STATE_PARTIALLY_FILLED;
               gap.freshness *= 0.5;
            }
         }
         else if(curPrice > gap.upperPrice) // Invalidated if price breaks completely above FVG top
         {
            gap.lifecycleState = FVG_STATE_COMPLETELY_FILLED;
            gap.fillPercentage = 100.0;
            gap.freshness = 0.0;
         }
      }
   }
};
