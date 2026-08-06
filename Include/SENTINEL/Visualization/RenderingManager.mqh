//+------------------------------------------------------------------+
//|                                             RenderingManager.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Framework/Context/MarketContext.mqh"
#include "VisualizationConfiguration.mqh"
#include "LayerManager.mqh"
#include "ObjectPoolRenderer.mqh"
#include "ThemeManager.mqh"
#include "OverlayManager.mqh"
#include "PerformanceOverlay.mqh"

/// @class CRenderingManager
/// @brief High-level rendering orchestrator executing dirty-flag update cycles and rate limits.
class CRenderingManager
{
private:
   CObjectPoolRenderer m_pool;
   CLayerManager       m_layerManager;
   CPerformanceOverlay m_perfOverlay;
   ulong               m_lastSequenceRendered;

public:
   CRenderingManager() : m_lastSequenceRendered(0) {}

   void Initialize(long chartId)
   {
      m_pool.Initialize(chartId);
      m_lastSequenceRendered = 0;
   }

   /// @brief Gets LayerManager reference.
   CLayerManager* GetLayerManager() { return GetPointer(m_layerManager); }

   /// @brief Gets ObjectPoolRenderer reference.
   CObjectPoolRenderer* GetObjectPool() { return GetPointer(m_pool); }

   /// @brief Executes a rendering frame cycle.
   bool RenderFrame(const SMarketContext &context, const SVisualizationConfiguration &config)
   {
      // Check sequence dirty flag
      if(context.sequenceNumber == m_lastSequenceRendered && m_lastSequenceRendered > 0)
         return true; // No re-render required

      m_pool.ClearPool();

      SColorPalette palette = CThemeManager::GetPalette(config.theme);

      // Render overlays across active layers
      COverlayManager::RenderOverlays(context, m_layerManager, palette, m_pool);

      // Flush to chart canvas
      m_pool.Flush();

      m_lastSequenceRendered = context.sequenceNumber;
      m_perfOverlay.RecordFrame();
      return true;
   }

   /// @brief Purges chart objects.
   void Purge()
   {
      m_pool.Purge();
      m_lastSequenceRendered = 0;
   }
};
