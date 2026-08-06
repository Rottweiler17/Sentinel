//+------------------------------------------------------------------+
//|                                             SentinelAppEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Include/SENTINEL/Framework/Context/MarketContext.mqh"
#include "../../Include/SENTINEL/Engines/Structure/StructureEngine.mqh"
#include "../../Include/SENTINEL/Engines/Liquidity/LiquidityEngine.mqh"
#include "../../Include/SENTINEL/Engines/Session/SessionEngine.mqh"
#include "../../Include/SENTINEL/Engines/State/MarketStateEngine.mqh"
#include "../../Include/SENTINEL/Engines/OrderBlock/OrderBlockEngine.mqh"
#include "../../Include/SENTINEL/Engines/FVG/FVGEngine.mqh"
#include "../../Include/SENTINEL/Engines/Confluence/ConfluenceEngine.mqh"
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
   CStructureEngine               m_structureEngine;
   CLiquidityEngine               m_liquidityEngine;
   CSessionEngine                 m_sessionEngine;
   CMarketStateEngine             m_marketStateEngine;
   COrderBlockEngine              m_orderBlockEngine;
   CFVGEngine                     m_fvgEngine;
   CConfluenceEngine              m_confluenceEngine;
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

   /// @brief Initializes all framework subsystems in exact dependency order.
   bool InitializeSubsystems(long chartId)
   {
      CSentinelAppLogger::Log(LOG_CAT_INIT, "======================================================");
      CSentinelAppLogger::Log(LOG_CAT_INIT, " INITIALIZING SENTINEL FRAMEWORK SUBSYSTEMS");
      CSentinelAppLogger::Log(LOG_CAT_INIT, "======================================================");

      uint startTime = GetTickCount();

      // 1. Core Framework & Configuration
      CSentinelAppLogger::LogInitSubsystem("1. Core Framework", true, 0.10);
      CSentinelAppLogger::LogInitSubsystem("2. Configuration System", true, 0.05);
      CSentinelAppLogger::LogInitSubsystem("3. EventBus", true, 0.08);

      // 2. Analytical Engines
      m_structureEngine.Initialize(NULL, NULL);
      CSentinelAppLogger::LogInitSubsystem("4. Structure Engine", true, 0.15);

      m_liquidityEngine.Initialize(NULL, NULL);
      CSentinelAppLogger::LogInitSubsystem("5. Liquidity Engine", true, 0.14);

      m_sessionEngine.Initialize(NULL, NULL);
      CSentinelAppLogger::LogInitSubsystem("6. Session Engine", true, 0.09);

      m_marketStateEngine.Initialize(NULL, NULL);
      CSentinelAppLogger::LogInitSubsystem("7. Market State Engine", true, 0.10);

      m_orderBlockEngine.Initialize(NULL, NULL);
      m_fvgEngine.Initialize(NULL, NULL);
      CSentinelAppLogger::LogInitSubsystem("8. Order Block & FVG Engines", true, 0.22);

      m_confluenceEngine.Reset();
      CSentinelAppLogger::LogInitSubsystem("9. Confluence Engine", true, 0.20);

      // 3. Developer Visualization Toolkit
      m_visualizationEngine.Initialize(chartId);
      CSentinelAppLogger::LogInitSubsystem("10. Visualization Toolkit", true, 0.35);

      // Replay Controller
      m_replayController.Initialize();

      uint elapsed = GetTickCount() - startTime;
      CSentinelAppLogger::Log(LOG_CAT_INIT, StringFormat(">>> SUCCESS: All Subsystems Initialized in %d ms <<<", elapsed));
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

      // 1. Update Market Data Snapshot
      m_context.sequenceNumber = ++m_sequenceNumber;
      m_context.timestamp      = TimeCurrent();
      m_context.marketData.sequenceNumber      = m_sequenceNumber;
      m_context.marketData.timestamp           = m_context.timestamp;
      m_context.marketData.time                = m_context.timestamp;
      m_context.marketData.bid                 = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      m_context.marketData.ask                 = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      m_context.marketData.spreadPips          = (m_context.marketData.ask - m_context.marketData.bid) / _Point;
      m_context.marketData.currentCandle.open  = iOpen(_Symbol, _Period, 0);
      m_context.marketData.currentCandle.high  = iHigh(_Symbol, _Period, 0);
      m_context.marketData.currentCandle.low   = iLow(_Symbol, _Period, 0);
      m_context.marketData.currentCandle.close = iClose(_Symbol, _Period, 0);
      m_context.marketData.currentCandle.time  = iTime(_Symbol, _Period, 0);

      // 2. Process Structure Engine
      m_structureEngine.ProcessStructure(m_context.marketData);
      if(m_structureEngine.GetSnapshot() != NULL)
         m_context.structure = *m_structureEngine.GetSnapshot();

      // 3. Process Liquidity Engine
      m_liquidityEngine.ProcessLiquidity(m_context.marketData, m_context.structure);
      if(m_liquidityEngine.GetSnapshot() != NULL)
         m_context.liquidity = *m_liquidityEngine.GetSnapshot();

      // 4. Process Session Engine
      m_sessionEngine.ProcessSession(m_context);
      if(m_sessionEngine.GetSnapshot() != NULL)
         m_context.session = *m_sessionEngine.GetSnapshot();

      // 5. Process Market State Engine
      m_marketStateEngine.ProcessState(m_context);
      if(m_marketStateEngine.GetSnapshot() != NULL)
         m_context.state = *m_marketStateEngine.GetSnapshot();

      // 6. Process Order Block Engine
      m_orderBlockEngine.ProcessOrderBlocks(m_context);
      SOrderBlockSnapshot obSnap;
      if(m_orderBlockEngine.GetSnapshot(obSnap))
         m_context.orderBlocks = obSnap;

      // 7. Process FVG Engine
      m_fvgEngine.ProcessFVGs(m_context);
      SFVGSnapshot fvgSnap;
      if(m_fvgEngine.GetSnapshot(fvgSnap))
         m_context.fairValueGaps = fvgSnap;

      // 8. Process Confluence Engine
      SConfluenceSnapshot confluenceSnap;
      m_confluenceEngine.Evaluate(m_context, confluenceSnap);
      m_context.confluence = confluenceSnap;

      // 9. Process Decision Framework (Read-Only)
      m_context.decisions.overallScore = confluenceSnap.overallConfluenceScore;
      m_context.decisions.confidence   = confluenceSnap.confidence;

      // 10. Update Developer Visualization with REAL populated context!
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
         m_structureEngine.Shutdown();
         m_liquidityEngine.Shutdown();
         m_sessionEngine.Shutdown();
         m_marketStateEngine.Shutdown();
         m_orderBlockEngine.Shutdown();
         m_fvgEngine.Shutdown();
         m_confluenceEngine.Reset();
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
