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

      // 1. Structure Layer (Swing Highs/Lows, BOS/CHOCH)
      if(layerManager.IsLayerVisible(LAYER_STRUCTURE))
      {
         int objIdx = pool.AcquireObject(LAYER_STRUCTURE, OBJ_HLINE, "SwingHigh");
         if(objIdx >= 0)
            pool.SetObjectDetails(objIdx, now, context.marketData.high + 10.0*_Point, 0, 0.0, palette.bullish, 1, "Swing High");

         objIdx = pool.AcquireObject(LAYER_STRUCTURE, OBJ_HLINE, "SwingLow");
         if(objIdx >= 0)
            pool.SetObjectDetails(objIdx, now, context.marketData.low - 10.0*_Point, 0, 0.0, palette.bearish, 1, "Swing Low");
      }

      // 2. Liquidity Layer (BSL/SSL Sweeps)
      if(layerManager.IsLayerVisible(LAYER_LIQUIDITY))
      {
         if(context.liquidity.sellSideSweepActive)
         {
            int objIdx = pool.AcquireObject(LAYER_LIQUIDITY, OBJ_ARROW, "SSLSweep");
            if(objIdx >= 0)
               pool.SetObjectDetails(objIdx, now, context.marketData.low, 0, 0.0, palette.bullish, 2, "SSL Sweep");
         }
         if(context.liquidity.buySideSweepActive)
         {
            int objIdx = pool.AcquireObject(LAYER_LIQUIDITY, OBJ_ARROW, "BSLSweep");
            if(objIdx >= 0)
               pool.SetObjectDetails(objIdx, now, context.marketData.high, 0, 0.0, palette.bearish, 2, "BSL Sweep");
         }
      }

      // 3. Order Block Layer (Bullish/Bearish OBs)
      if(layerManager.IsLayerVisible(LAYER_ORDER_BLOCKS))
      {
         if(context.orderBlocks.activeBullishObCount > 0)
         {
            int objIdx = pool.AcquireObject(LAYER_ORDER_BLOCKS, OBJ_RECTANGLE, "BullishOB");
            if(objIdx >= 0)
               pool.SetObjectDetails(objIdx, now - 3600, context.marketData.low - 5.0*_Point, now, context.marketData.low + 5.0*_Point, palette.bullish, 1, "Bullish OB");
         }
         if(context.orderBlocks.activeBearishObCount > 0)
         {
            int objIdx = pool.AcquireObject(LAYER_ORDER_BLOCKS, OBJ_RECTANGLE, "BearishOB");
            if(objIdx >= 0)
               pool.SetObjectDetails(objIdx, now - 3600, context.marketData.high - 5.0*_Point, now, context.marketData.high + 5.0*_Point, palette.bearish, 1, "Bearish OB");
         }
      }

      // 4. Fair Value Gap Layer (FVG)
      if(layerManager.IsLayerVisible(LAYER_FVG))
      {
         if(context.fairValueGaps.unfilledBullishFvgCount > 0)
         {
            int objIdx = pool.AcquireObject(LAYER_FVG, OBJ_RECTANGLE, "BullishFVG");
            if(objIdx >= 0)
               pool.SetObjectDetails(objIdx, now - 1800, context.marketData.close - 2.0*_Point, now, context.marketData.close + 2.0*_Point, palette.activeZone, 1, "Bullish FVG");
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
