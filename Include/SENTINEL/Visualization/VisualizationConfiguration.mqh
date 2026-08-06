//+------------------------------------------------------------------+
//|                                   VisualizationConfiguration.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "VisualizationTypes.mqh"

/// @struct SVisualizationConfiguration
/// @brief Configuration settings governing visualization rendering, themes, and limits.
struct SVisualizationConfiguration
{
   bool                     overlayEnabled[LAYER_COUNT];
   int                      maxVisibleObjects;
   int                      refreshRateMs;
   int                      defaultLineWidth;
   int                      defaultFontSize;
   ENUM_VISUALIZATION_THEME theme;

   bool                     enableValidationMode;
   bool                     showDebugPanel;
   bool                     showPerformanceOverlay;
   int                      debugPanelX;
   int                      debugPanelY;

   void SetDefaults()
   {
      for(int i = 0; i < (int)LAYER_COUNT; i++)
         overlayEnabled[i] = true;

      maxVisibleObjects      = 500;
      refreshRateMs          = 100;
      defaultLineWidth       = 1;
      defaultFontSize        = 9;
      theme                  = THEME_DARK;

      enableValidationMode   = true;
      showDebugPanel         = true;
      showPerformanceOverlay = true;
      debugPanelX            = 20;
      debugPanelY            = 30;
   }
};
