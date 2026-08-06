//+------------------------------------------------------------------+
//|                                   Phase16VisualizationTest.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Visualization/VisualizationEngine.mqh"

/// @class CPhase16VisualizationTest
/// @brief Unit test suite validating Visualization Toolkit layers, object pools, themes, debug panel, and validation mode.
class CPhase16VisualizationTest
{
public:
   static bool RunAllTests()
   {
      Print("=== Running Phase 16 Developer Visualization Toolkit Unit Tests ===");
      bool pass = true;

      pass &= TestLayerManagement();
      pass &= TestThemePalettes();
      pass &= TestObjectPoolRendering();
      pass &= TestDebugPanelFormatting();
      pass &= TestValidationModeInspection();

      if(pass)
         Print("[SUCCESS] All Phase 16 Visualization Toolkit Unit Tests Passed!");
      else
         Print("[FAIL] One or more Phase 16 Unit Tests Failed!");

      return pass;
   }

private:
   static bool TestLayerManagement()
   {
      CLayerManager layerMgr;
      layerMgr.SetLayerVisible(LAYER_STRUCTURE, false);
      if(layerMgr.IsLayerVisible(LAYER_STRUCTURE))
      {
         Print("  [FAIL] TestLayerManagement: LAYER_STRUCTURE should be disabled");
         return false;
      }
      layerMgr.EnableAllLayers();
      if(!layerMgr.IsLayerVisible(LAYER_STRUCTURE))
      {
         Print("  [FAIL] TestLayerManagement: EnableAllLayers failed");
         return false;
      }
      Print("  [PASS] TestLayerManagement Passed!");
      return true;
   }

   static bool TestThemePalettes()
   {
      SColorPalette darkPalette = CThemeManager::GetPalette(THEME_DARK);
      SColorPalette lightPalette = CThemeManager::GetPalette(THEME_LIGHT);

      if(darkPalette.background == lightPalette.background)
      {
         Print("  [FAIL] TestThemePalettes: Dark and Light themes should differ");
         return false;
      }
      Print("  [PASS] TestThemePalettes Passed!");
      return true;
   }

   static bool TestObjectPoolRendering()
   {
      CObjectPoolRenderer pool;
      pool.Initialize(0);

      int idx1 = pool.AcquireObject(LAYER_STRUCTURE, OBJ_RECTANGLE, "TestOB");
      int idx2 = pool.AcquireObject(LAYER_LIQUIDITY, OBJ_ARROW, "TestSweep");

      if(idx1 < 0 || idx2 < 0 || pool.GetActiveCount() != 2)
      {
         Print("  [FAIL] TestObjectPoolRendering: Object pool acquisition failed");
         return false;
      }

      pool.ClearPool();
      if(pool.GetActiveCount() != 0)
      {
         Print("  [FAIL] TestObjectPoolRendering: ClearPool failed");
         return false;
      }

      Print("  [PASS] TestObjectPoolRendering Passed!");
      return true;
   }

   static bool TestDebugPanelFormatting()
   {
      SMarketContext context;
      context.Reset();
      context.structure.trend = 1;
      context.liquidity.sellSideSweepActive = true;

      string output = CDebugPanel::FormatDebugContent(context, 60.0, 0.15);
      if(StringFind(output, "SENTINEL FRAMEWORK DEBUG PANEL") < 0 ||
         StringFind(output, "BULLISH") < 0)
      {
         Print("  [FAIL] TestDebugPanelFormatting: Output missing required headers");
         return false;
      }

      Print("  [PASS] TestDebugPanelFormatting Passed!");
      return true;
   }

   static bool TestValidationModeInspection()
   {
      CValidationModeOverlay validationOverlay;
      validationOverlay.SetActive(true);
      validationOverlay.SelectCandle(15, TimeCurrent());

      if(!validationOverlay.IsActive() || validationOverlay.GetSelectedBarIndex() != 15)
      {
         Print("  [FAIL] TestValidationModeInspection: Selected candle index mismatch");
         return false;
      }

      SMarketContext context;
      context.Reset();
      string valOutput = CValidationModeOverlay::FormatValidationOutput(context, 15);
      if(StringFind(valOutput, "CANDLE VALIDATION SNAPSHOT INSPECTION") < 0)
      {
         Print("  [FAIL] TestValidationModeInspection: Format output missing");
         return false;
      }

      Print("  [PASS] TestValidationModeInspection Passed!");
      return true;
   }
};
