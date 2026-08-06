//+------------------------------------------------------------------+
//|                                               OverlayManager.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "ObjectPoolRenderer.mqh"
#include "LayerManager.mqh"
#include "ThemeManager.mqh"

/// @class COverlayManager
/// @brief Specific overlay renderer translating MarketContext snapshots into pooled chart objects.
class COverlayManager
{
public:
   /// @brief Renders analytical overlay graphics across active layers.
   static void RenderOverlays(const SMarketContext &context,
                              CLayerManager &layerManager,
                              const SColorPalette &palette,
                              CObjectPoolRenderer &pool)
   {
      datetime now = context.timestamp;
      if(now == 0) now = TimeCurrent();

      double highPrice  = context.marketData.currentCandle.high;
      double lowPrice   = context.marketData.currentCandle.low;
      double closePrice = context.marketData.currentCandle.close;

      if(highPrice == 0.0) highPrice = context.marketData.bid + 10.0 * _Point;
      if(lowPrice == 0.0)  lowPrice  = context.marketData.bid - 10.0 * _Point;

      // 1. Structure Layer (Swing Highs/Lows, BOS/CHOCH)
      if(layerManager.IsLayerVisible(LAYER_STRUCTURE))
      {
         int objIdx = pool.AcquireObject(LAYER_STRUCTURE, OBJ_HLINE, "SwingHigh");
         if(objIdx >= 0)
            pool.SetObjectDetails(objIdx, now, highPrice + 10.0*_Point, 0, 0.0, palette.bullish, 1, "Swing High");

         objIdx = pool.AcquireObject(LAYER_STRUCTURE, OBJ_HLINE, "SwingLow");
         if(objIdx >= 0)
            pool.SetObjectDetails(objIdx, now, lowPrice - 10.0*_Point, 0, 0.0, palette.bearish, 1, "Swing Low");
      }

      // 2. Liquidity Layer (BSL/SSL Sweeps)
      if(layerManager.IsLayerVisible(LAYER_LIQUIDITY))
      {
         if(context.liquidity.sweepDirection == SWEEP_BULLISH)
         {
            int objIdx = pool.AcquireObject(LAYER_LIQUIDITY, OBJ_ARROW, "SSLSweep");
            if(objIdx >= 0)
               pool.SetObjectDetails(objIdx, now, lowPrice, 0, 0.0, palette.bullish, 2, "Bullish Sweep");
         }
         if(context.liquidity.sweepDirection == SWEEP_BEARISH)
         {
            int objIdx = pool.AcquireObject(LAYER_LIQUIDITY, OBJ_ARROW, "BSLSweep");
            if(objIdx >= 0)
               pool.SetObjectDetails(objIdx, now, highPrice, 0, 0.0, palette.bearish, 2, "Bearish Sweep");
         }
      }

      // 3. Order Block Layer (Bullish/Bearish OBs)
      if(layerManager.IsLayerVisible(LAYER_ORDER_BLOCKS))
      {
         if(context.orderBlocks.activeBlocksCount > 0)
         {
            int objIdx = pool.AcquireObject(LAYER_ORDER_BLOCKS, OBJ_RECTANGLE, "ActiveOB");
            if(objIdx >= 0)
               pool.SetObjectDetails(objIdx, now - 3600, lowPrice - 5.0*_Point, now, lowPrice + 5.0*_Point, palette.bullish, 1, "Active OB");
         }
      }

      // 4. Fair Value Gap Layer (FVG)
      if(layerManager.IsLayerVisible(LAYER_FVG))
      {
         if(context.fairValueGaps.activeGapsCount > 0)
         {
            int objIdx = pool.AcquireObject(LAYER_FVG, OBJ_RECTANGLE, "ActiveFVG");
            if(objIdx >= 0)
               pool.SetObjectDetails(objIdx, now - 1800, closePrice - 2.0*_Point, now, closePrice + 2.0*_Point, palette.activeZone, 1, "Active FVG");
         }
      }

      // 5. Session Layer
      if(layerManager.IsLayerVisible(LAYER_SESSIONS))
      {
         int objIdx = pool.AcquireObject(LAYER_SESSIONS, OBJ_VLINE, "SessionStart");
         if(objIdx >= 0)
            pool.SetObjectDetails(objIdx, now - 7200, 0.0, 0, 0.0, palette.textSecondary, 1, "Session Boundary");
      }
   }
};
