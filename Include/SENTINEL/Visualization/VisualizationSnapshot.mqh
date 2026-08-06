//+------------------------------------------------------------------+
//|                                        VisualizationSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "VisualizationTypes.mqh"

/// @struct SVisualizationSnapshot
/// @brief Immutable snapshot representing active render state, layer visibility, and telemetry.
struct SVisualizationSnapshot
{
   ulong                      snapshotId;
   ulong                      sequenceNumber;
   datetime                   timestamp;

   bool                       layerActive[LAYER_COUNT];
   int                        totalActiveObjects;
   int                        poolSize;
   ENUM_VISUALIZATION_THEME   theme;

   bool                       validationModeActive;
   int                        selectedValidationBar;
   datetime                   selectedValidationTime;

   void Reset()
   {
      snapshotId             = 0;
      sequenceNumber         = 0;
      timestamp              = 0;

      for(int i = 0; i < (int)LAYER_COUNT; i++)
         layerActive[i] = true;

      totalActiveObjects     = 0;
      poolSize               = 0;
      theme                  = THEME_DARK;

      validationModeActive   = false;
      selectedValidationBar  = -1;
      selectedValidationTime = 0;
   }
};
