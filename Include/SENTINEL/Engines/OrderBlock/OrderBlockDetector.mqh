//+------------------------------------------------------------------+
//|                                          OrderBlockDetector.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "OrderBlockTypes.mqh"
#include "OrderBlockConfiguration.mqh"
#include "../../Framework/Context/MarketContext.mqh"

/// @class COrderBlockDetector
/// @brief Discovers high-probability Order Blocks based on market structure breaks & volume validation.
class COrderBlockDetector
{
private:
   static ulong m_idSeq;

public:
   /// @brief Scans MarketContext for new Order Block formations.
   static bool Detect(const SMarketContext &context,
                      const COrderBlockConfiguration &config,
                      SOrderBlock &outBlock)
   {
      // Safe fallback checks
      if(context.structure.latestSwingHigh.price <= 0.0) return false;

      // Detect potential block when a Structure event (like BOS) occurs with high volume confirmation
      if(context.structure.latestBOS.type != BREAK_NONE && context.volume.volumeState == VOLUME_STATE_SPIKE)
      {
         m_idSeq++;
         outBlock.id = m_idSeq;
         outBlock.creationTime = context.marketData.time;
         outBlock.lifecycleState = ORDERBLOCK_STATE_CREATED;
         outBlock.retestCount = 0;
         outBlock.isMitigated = false;

         if(context.structure.latestBOS.type == BREAK_BOS_BULLISH) // Bullish BOS -> Bullish OB (demand zone)
         {
            outBlock.direction  = ORDERBLOCK_BULLISH;
            outBlock.lowerPrice = context.structure.latestSwingLow.price;
            outBlock.upperPrice = outBlock.lowerPrice + (context.marketData.spread * 5.0);
            outBlock.midPrice   = (outBlock.lowerPrice + outBlock.upperPrice) / 2.0;
            outBlock.strength   = context.structure.trendStrength;
            outBlock.confidence = context.features.buyingPressure.confidence;
            outBlock.freshness  = 100.0;
            return true;
         }
         else if(context.structure.latestBOS.type == BREAK_BOS_BEARISH) // Bearish BOS -> Bearish OB (supply zone)
         {
            outBlock.direction  = ORDERBLOCK_BEARISH;
            outBlock.upperPrice = context.structure.latestSwingHigh.price;
            outBlock.lowerPrice = outBlock.upperPrice - (context.marketData.spread * 5.0);
            outBlock.midPrice   = (outBlock.lowerPrice + outBlock.upperPrice) / 2.0;
            outBlock.strength   = context.structure.trendStrength;
            outBlock.confidence = context.features.sellingPressure.confidence;
            outBlock.freshness  = 100.0;
            return true;
         }
      }

      return false;
   }
};

ulong COrderBlockDetector::m_idSeq = 0;
