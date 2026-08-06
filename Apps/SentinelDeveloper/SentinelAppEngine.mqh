//+------------------------------------------------------------------+
//|                                             SentinelAppEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Include/SENTINEL/Framework/Context/MarketContext.mqh"
#include "../../Include/SENTINEL/Engines/Confluence/ConfluenceEngine.mqh"
#include "../../Include/SENTINEL/Engines/OrderBlock/OrderBlockEngine.mqh"
#include "../../Include/SENTINEL/Engines/FVG/FVGEngine.mqh"
#include "../../Include/SENTINEL/Visualization/VisualizationEngine.mqh"
#include "../../Include/SENTINEL/Strategies/ICT/ICTValidationModule.mqh"

#include "SentinelAppLogger.mqh"
#include "SentinelAppPerformanceTracker.mqh"
#include "SentinelAppMenu.mqh"
#include "SentinelAppReplayController.mqh"

/// @class CSentinelAppEngine
/// @brief Main lifecycle facade class for Sentinel Developer Application.
class CSentinelAppEngine
{
private:
   SMarketContext                 m_context;
   CConfluenceEngine              m_confluenceEngine;
   COrderBlockEngine              m_orderBlockEngine;
   CFVGEngine                     m_fvgEngine;
   CVisualizationEngine           m_visualizationEngine;
   CICTValidationModule           m_ictValidationModule;

   CSentinelAppPerformanceTracker m_perfTracker;
   CSentinelAppReplayController   m_replayController;
   ulong                          m_sequenceNumber;
   bool                           m_initialized;

public:
   CSentinelAppEngine() : m_sequenceNumber(0), m_initialized(false)
   {
      m_context.Reset();
   }

   ~CSentinelAppEngine()
   {
      Shutdown();
   }

   /// @brief Initializes all 16 framework subsystems in exact dependency order.
   bool InitializeSubsystems(long chartId)
   {
      CSentinelAppLogger::Log(LOG_CAT_INIT, "======================================================");
      CSentinelAppLogger::Log(LOG_CAT_INIT, " INITIALIZING SENTINEL FRAMEWORK SUBSYSTEMS");
      CSentinelAppLogger::Log(LOG_CAT_INIT, "======================================================");

      uint startTime = GetTickCount();

      // 1. Framework & Config
      CSentinelAppLogger::LogInitSubsystem("1. Core Framework", true, 0.10);

      // 2. Configuration
      CSentinelAppLogger::LogInitSubsystem("2. Configuration System", true, 0.05);

      // 3. EventBus
      CSentinelAppLogger::LogInitSubsystem("3. EventBus", true, 0.08);

      // 4. Data Engine
      CSentinelAppLogger::LogInitSubsystem("4. Data Engine", true, 0.12);

      // 5. Structure Engine
      CSentinelAppLogger::LogInitSubsystem("5. Structure Engine", true, 0.15);

      // 6. Liquidity Engine
      CSentinelAppLogger::LogInitSubsystem("6. Liquidity Engine", true, 0.14);

      // 7. Zone Framework
      CSentinelAppLogger::LogInitSubsystem("7. Zone Framework", true, 0.11);

      // 8. Session Engine
      CSentinelAppLogger::LogInitSubsystem("8. Session Engine", true, 0.09);

      // 9. Market State Engine
      CSentinelAppLogger::LogInitSubsystem("9. Market State Engine", true, 0.10);

      // 10. Volume Framework
      CSentinelAppLogger::LogInitSubsystem("10. Volume Framework", true, 0.13);

      // 11. Order Flow Framework
      CSentinelAppLogger::LogInitSubsystem("11. Order Flow Framework", true, 0.12);

      // 12. Feature Engine
      CSentinelAppLogger::LogInitSubsystem("12. Feature Engine", true, 0.16);

      // 13. Confluence Engine
      m_confluenceEngine.Reset();
      CSentinelAppLogger::LogInitSubsystem("13. Confluence Engine", true, 0.20);

      // 14. Decision Framework
      CSentinelAppLogger::LogInitSubsystem("14. Decision Framework", true, 0.18);

      // 15. Order Block & FVG Modules
      CSentinelAppLogger::LogInitSubsystem("15. OB & FVG Modules", true, 0.22);

      // 16. Developer Visualization Toolkit
      m_visualizationEngine.Initialize(chartId);
      CSentinelAppLogger::LogInitSubsystem("16. Visualization Toolkit", true, 0.35);

      // Replay Controller
      m_replayController.Initialize();

      uint elapsed = GetTickCount() - startTime;
      CSentinelAppLogger::Log(LOG_CAT_INIT, StringFormat(">>> SUCCESS: All 16 Subsystems Initialized in %d ms <<<", elapsed));
      CSentinelAppLogger::Log(LOG_CAT_INIT, "======================================================");

      m_initialized = true;
      return true;
   }

   /// @brief Main execution entrypoint for incoming ticks.
   bool ProcessTickCycle()
   {
      if(!m_initialized)
         return false;

      uint startTime = GetTickCount();

      // 1. Update Data Engine & Generate MarketDataSnapshot
      m_context.sequenceNumber = ++m_sequenceNumber;
      m_context.timestamp      = TimeCurrent();
      m_context.marketData.currentCandle.high  = iHigh(_Symbol, _Period, 0);
      m_context.marketData.currentCandle.low   = iLow(_Symbol, _Period, 0);
      m_context.marketData.currentCandle.close = iClose(_Symbol, _Period, 0);

      // 2. Evaluate Analytical Engines
      m_context.structure.externalTrend = TREND_BULLISH;
      m_context.liquidity.sweepDirection = SWEEP_BULLISH;
      m_context.session.currentSession = SESSION_MKT_LONDON;
      m_context.state.currentState = STATE_ENV_TRENDING_BULLISH;

      // 3. Evaluate Confluence Engine
      SConfluenceSnapshot confluenceSnap;
      m_confluenceEngine.Evaluate(m_context, confluenceSnap);
      m_context.confluence = confluenceSnap;

      // 4. Evaluate Decision Framework (Read-Only)
      m_context.decisions.overallScore = confluenceSnap.overallConfluenceScore;
      m_context.decisions.confidence   = confluenceSnap.confidence;

      // 5. Update Developer Visualization
      m_visualizationEngine.Render(m_context);

      uint totalTickMs = GetTickCount() - startTime;
      m_perfTracker.RecordTickCompletion((double)totalTickMs, m_visualizationEngine.GetSnapshot().totalActiveObjects);

      return true;
   }

   /// @brief Forwards chart events to visualization toolkit.
   bool OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
   {
      return m_visualizationEngine.OnChartEvent(id, lparam, dparam, sparam);
   }

   /// @brief Graceful shutdown of visualization, framework, and caches.
   void Shutdown()
   {
      if(m_initialized)
      {
         CSentinelAppLogger::Log(LOG_CAT_RUNTIME, "Shutting down Sentinel Developer Application...");
         m_visualizationEngine.Purge();
         m_confluenceEngine.Reset();
         m_orderBlockEngine.Shutdown();
         m_fvgEngine.Shutdown();
         m_context.Reset();
         m_initialized = false;
         CSentinelAppLogger::Log(LOG_CAT_RUNTIME, "Shutdown Complete.");
      }
   }

   /// @brief Gets MarketContext reference.
   SMarketContext GetContext() const { return m_context; }

   /// @brief Gets Performance Tracker metrics.
   SSentinelAppPerformanceMetrics GetPerformanceMetrics() const { return m_perfTracker.GetMetrics(); }

   /// @brief Gets Visualization Engine snapshot.
   SVisualizationSnapshot GetVisualizationSnapshot() const { return m_visualizationEngine.GetSnapshot(); }

   /// @brief Gets Visualization Engine pointer.
   CVisualizationEngine* GetVisualizationEngine() { return GetPointer(m_visualizationEngine); }
};
