//+------------------------------------------------------------------+
//|                                          VisualizationEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "IVisualizationEngine.mqh"
#include "RenderingManager.mqh"
#include "DebugPanel.mqh"
#include "ValidationModeOverlay.mqh"
#include "VisualizationEvents.mqh"

/// @class CVisualizationEngine
/// @brief Primary facade class for Developer Visualization & Validation Toolkit.
class CVisualizationEngine : public IVisualizationEngine
{
private:
   SVisualizationConfiguration m_config;
   CRenderingManager           m_renderingManager;
   CDebugPanel                 m_debugPanel;
   CValidationModeOverlay      m_validationOverlay;
   SVisualizationSnapshot      m_snapshot;
   long                        m_chartId;
   ulong                       m_sequenceNumber;

public:
   CVisualizationEngine() : m_chartId(0), m_sequenceNumber(0)
   {
      m_config.SetDefaults();
      m_snapshot.Reset();
   }

   virtual ~CVisualizationEngine()
   {
      Purge();
   }

   /// @brief Initializes chart canvas ID.
   virtual void Initialize(long chartId) override
   {
      m_chartId = chartId;
      m_renderingManager.Initialize(chartId);
      m_debugPanel.Initialize(chartId, m_config.debugPanelX, m_config.debugPanelY);
   }

   /// @brief Main execution entrypoint rendering snapshots onto chart.
   virtual bool Render(const SMarketContext &context) override
   {
      if(m_chartId == 0) m_chartId = ChartID();

      // Execute main render frame cycle
      bool result = m_renderingManager.RenderFrame(context, m_config);

      // Update state snapshot
      m_snapshot.snapshotId         = ++m_sequenceNumber;
      m_snapshot.sequenceNumber     = m_sequenceNumber;
      m_snapshot.timestamp          = context.timestamp;
      m_snapshot.theme              = m_config.theme;
      m_snapshot.totalActiveObjects = m_renderingManager.GetObjectPool().GetActiveCount();
      m_snapshot.poolSize           = m_renderingManager.GetObjectPool().GetPoolSize();
      m_snapshot.validationModeActive = m_validationOverlay.IsActive();
      m_snapshot.selectedValidationBar = m_validationOverlay.GetSelectedBarIndex();
      m_snapshot.selectedValidationTime = m_validationOverlay.GetSelectedBarTime();

      for(int i = 0; i < (int)LAYER_COUNT; i++)
         m_snapshot.layerActive[i] = m_renderingManager.GetLayerManager().IsLayerVisible((ENUM_VISUALIZATION_LAYER)i);

      return result;
   }

   /// @brief Retrieves current configuration settings.
   virtual SVisualizationConfiguration GetConfiguration() const override
   {
      return m_config;
   }

   /// @brief Updates configuration settings.
   virtual void SetConfiguration(const SVisualizationConfiguration &config) override
   {
      m_config = config;
   }

   /// @brief Retrieves current visualization state snapshot.
   virtual SVisualizationSnapshot GetSnapshot() const override
   {
      return m_snapshot;
   }

   /// @brief Enables or disables a specific rendering layer.
   virtual void SetLayerVisible(ENUM_VISUALIZATION_LAYER layer, bool visible) override
   {
      m_renderingManager.GetLayerManager().SetLayerVisible(layer, visible);
      m_config.overlayEnabled[(int)layer] = visible;
   }

   /// @brief Toggles Validation Mode.
   virtual void SetValidationMode(bool active) override
   {
      m_validationOverlay.SetActive(active);
      m_config.enableValidationMode = active;
   }

   /// @brief Forwards chart event to visualization handlers.
   bool OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
   {
      return CVisualizationEvents::OnChartEvent(id, lparam, dparam, sparam, m_validationOverlay);
   }

   /// @brief Clears and purges chart objects.
   virtual void Purge() override
   {
      m_renderingManager.Purge();
      m_snapshot.Reset();
   }
};
