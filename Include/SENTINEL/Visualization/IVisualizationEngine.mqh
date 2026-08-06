//+------------------------------------------------------------------+
//|                                         IVisualizationEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "VisualizationSnapshot.mqh"
#include "VisualizationConfiguration.mqh"

/// @interface IVisualizationEngine
/// @brief Contract interface for Developer Visualization Engine implementations.
interface IVisualizationEngine
{
public:
   virtual void                         Initialize(long chartId) = 0;
   virtual bool                         Render(const SMarketContext &context) = 0;
   virtual SVisualizationConfiguration  GetConfiguration() const = 0;
   virtual void                         SetConfiguration(const SVisualizationConfiguration &config) = 0;
   virtual SVisualizationSnapshot       GetSnapshot() const = 0;
   virtual void                         SetLayerVisible(ENUM_VISUALIZATION_LAYER layer, bool visible) = 0;
   virtual void                         SetValidationMode(bool active) = 0;
   virtual void                         Purge() = 0;
};
