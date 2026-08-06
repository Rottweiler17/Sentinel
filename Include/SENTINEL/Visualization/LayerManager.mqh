//+------------------------------------------------------------------+
//|                                                 LayerManager.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "VisualizationTypes.mqh"

/// @class CLayerManager
/// @brief Manages 10 independent rendering layers and visibility states.
class CLayerManager
{
private:
   bool m_layerVisible[LAYER_COUNT];

public:
   CLayerManager()
   {
      for(int i = 0; i < (int)LAYER_COUNT; i++)
         m_layerVisible[i] = true;
   }

   /// @brief Enables or disables a specific rendering layer.
   void SetLayerVisible(ENUM_VISUALIZATION_LAYER layer, bool visible)
   {
      if(layer >= 0 && layer < LAYER_COUNT)
         m_layerVisible[(int)layer] = visible;
   }

   /// @brief Checks if a specific layer is visible.
   bool IsLayerVisible(ENUM_VISUALIZATION_LAYER layer) const
   {
      if(layer >= 0 && layer < LAYER_COUNT)
         return m_layerVisible[(int)layer];
      return false;
   }

   /// @brief Enables all layers.
   void EnableAllLayers()
   {
      for(int i = 0; i < (int)LAYER_COUNT; i++)
         m_layerVisible[i] = true;
   }

   /// @brief Disables all layers.
   void DisableAllLayers()
   {
      for(int i = 0; i < (int)LAYER_COUNT; i++)
         m_layerVisible[i] = false;
   }
};
