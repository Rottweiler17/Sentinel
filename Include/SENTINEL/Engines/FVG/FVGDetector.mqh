//+------------------------------------------------------------------+
//|                                                 FVGDetector.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Types.mqh"
#include "../../Framework/Context/MarketContext.mqh"
#include "FVGTypes.mqh"
#include "FVGConfiguration.mqh"

/// @class CFVGDetector
/// @brief Scans a 3-candle history sequence to identify Fair Value Gaps.
class CFVGDetector
{
private:
   static ulong m_idSeq;

public:
   /// @brief Scans 3 consecutive closed bars to detect FVG.
   /// @param bar0 The most recently closed bar (Candle i-1)
   /// @param bar1 The middle bar (Candle i-2)
   /// @param bar2 The oldest bar (Candle i-3)
   static bool Detect(const SBarData &bar0, const SBarData &bar1, const SBarData &bar2, 
                      const SMarketContext &context, const CFVGConfiguration &config, SFairValueGap &outGap)
   {
      double point = context.marketData.point;
      if(point <= 0.0) point = 0.00001;

      // 1. Bullish FVG detection: Candle 2 (bar2) High is below Candle 0 (bar0) Low
      double bullishGap = bar0.low - bar2.high;
      if(bullishGap >= config.MinGapSizePoints() * point)
      {
         m_idSeq++;
         outGap.id = m_idSeq;
         outGap.direction  = FVG_BULLISH;
         outGap.lowerPrice = bar2.high;
         outGap.upperPrice = bar0.low;
         outGap.midPrice   = (outGap.lowerPrice + outGap.upperPrice) / 2.0;
         outGap.gapSize    = bullishGap;
         outGap.creationTime = bar1.time;
         outGap.strength   = context.features.buyingPressure.rawValue;
         outGap.confidence = context.features.buyingPressure.confidence;
         outGap.freshness  = 100.0;
         outGap.fillPercentage = 0.0;
         outGap.touchCount = 0;
         outGap.lifecycleState = FVG_STATE_CREATED;
         return true;
      }

      // 2. Bearish FVG detection: Candle 2 (bar2) Low is above Candle 0 (bar0) High
      double bearishGap = bar2.low - bar0.high;
      if(bearishGap >= config.MinGapSizePoints() * point)
      {
         m_idSeq++;
         outGap.id = m_idSeq;
         outGap.direction  = FVG_BEARISH;
         outGap.lowerPrice = bar0.high;
         outGap.upperPrice = bar2.low;
         outGap.midPrice   = (outGap.lowerPrice + outGap.upperPrice) / 2.0;
         outGap.gapSize    = bearishGap;
         outGap.creationTime = bar1.time;
         outGap.strength   = context.features.sellingPressure.rawValue;
         outGap.confidence = context.features.sellingPressure.confidence;
         outGap.freshness  = 100.0;
         outGap.fillPercentage = 0.0;
         outGap.touchCount = 0;
         outGap.lifecycleState = FVG_STATE_CREATED;
         return true;
      }

      return false;
   }
};

ulong CFVGDetector::m_idSeq = 0;
