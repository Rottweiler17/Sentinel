//+------------------------------------------------------------------+
//|                                    OrderBlockLifecycleManager.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "OrderBlockTypes.mqh"
#include "OrderBlockConfiguration.mqh"

/// @class COrderBlockLifecycleManager
/// @brief Manages the validation, retests, mitigations, and expirations of tracked order blocks.
class COrderBlockLifecycleManager
{
public:
   static void UpdateLifecycle(const SMarketContext &context, const COrderBlockConfiguration &config, SOrderBlock &block)
   {
      if(block.isMitigated || block.lifecycleState == ORDERBLOCK_STATE_INVALIDATED)
         return;

      double curPrice = context.marketData.bid;

      // 1. Transition state from CREATED to ACTIVE
      if(block.lifecycleState == ORDERBLOCK_STATE_CREATED)
      {
         block.lifecycleState = ORDERBLOCK_STATE_ACTIVE;
      }

      // 2. Retest and Mitigation Check
      if(block.direction == ORDERBLOCK_BULLISH)
      {
         if(curPrice <= block.upperPrice && curPrice >= block.lowerPrice)
         {
            block.retestCount++;
            block.lifecycleState = ORDERBLOCK_STATE_RETESTED;
            block.freshness     *= 0.7; // Freshness decays on retest
         }
         
         // Mitigation condition: price breaks below the lower boundary of a demand block
         if(curPrice < block.lowerPrice)
         {
            block.isMitigated    = true;
            block.lifecycleState = ORDERBLOCK_STATE_MITIGATED;
            block.freshness      = 0.0;
         }
      }
      else if(block.direction == ORDERBLOCK_BEARISH)
      {
         if(curPrice >= block.lowerPrice && curPrice <= block.upperPrice)
         {
            block.retestCount++;
            block.lifecycleState = ORDERBLOCK_STATE_RETESTED;
            block.freshness     *= 0.7;
         }
         
         // Mitigation condition: price breaks above the upper boundary of a supply block
         if(curPrice > block.upperPrice)
         {
            block.isMitigated    = true;
            block.lifecycleState = ORDERBLOCK_STATE_MITIGATED;
            block.freshness      = 0.0;
         }
      }

      // 3. Expiration Check (Limit retest counts)
      if(block.retestCount >= config.RetestLimit())
      {
         block.lifecycleState = ORDERBLOCK_STATE_EXPIRED;
      }
   }
};
