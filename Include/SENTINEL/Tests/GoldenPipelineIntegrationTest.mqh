//+------------------------------------------------------------------+
//|                                   GoldenPipelineIntegrationTest.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Common/Interfaces.mqh"
#include "../Events/EventBus.mqh"
#include "../Events/EventRecorder.mqh"
#include "../Data/DataEngine.mqh"
#include "../Engines/Structure/StructureEngine.mqh"
#include "../Engines/Liquidity/LiquidityEngine.mqh"
#include "../Framework/Zones/ZoneEngine.mqh"
#include "../Engines/Session/SessionEngine.mqh"
#include "../Engines/State/MarketStateEngine.mqh"
#include "../Engines/Volume/VolumeEngine.mqh"
#include "../Engines/OrderFlow/OrderFlowEngine.mqh"
#include "../Framework/Features/FeatureEngine.mqh"
#include "../Framework/Decisions/DecisionEngine.mqh"
#include "../Engines/OrderBlock/OrderBlockEngine.mqh"
#include "../Engines/FVG/FVGEngine.mqh"
#include "../Framework/Context/ContextEngine.mqh"
#include "../Logging/Logger.mqh"

/// @class CGoldenPipelineIntegrationTest
/// @brief Unified Golden Integration Test executing the complete capability pipeline.
/// Pipeline order: MarketData -> Structure -> Liquidity -> Zones -> Sessions -> Market State -> Volume -> Order Flow -> Features -> Decisions -> Order Blocks -> FVG -> Context.
class CGoldenPipelineIntegrationTest
{
public:
   static bool RunSuite()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("GoldenPipeline", "=== Starting SENTINEL Golden Integration Test Suite ===");

      // 1. Core Config & Event Bus
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);
      config.SetDouble("features.min_normalized", -1.0);
      config.SetDouble("features.max_normalized", 1.0);
      config.SetDouble("decisions.confluence_threshold", 55.0);
      config.SetDouble("decisions.score_threshold", 50.0);
      config.SetDouble("orderblock.min_strength", 40.0);
      config.SetDouble("fvg.min_gap_size_points", 5.0);

      CEventBus bus;

      // 2. Instantiate and Initialize the Entire Engine Suite
      CDataEngine dataEngine;
      CStructureEngine structureEngine;
      CLiquidityEngine liquidityEngine(3.0);
      CZoneEngine zoneEngine;
      CSessionEngine sessionEngine;
      CMarketStateEngine stateEngine;
      CVolumeEngine volumeEngine;
      COrderFlowEngine orderFlowEngine;
      CFeatureEngine featureEngine;
      CDecisionEngine decisionEngine;
      COrderBlockEngine obEngine;
      CFVGEngine fvgEngine;
      CContextEngine contextEngine;

      if(!dataEngine.Initialize(&config, &bus) || 
         !structureEngine.Initialize(&config, &bus) || 
         !liquidityEngine.Initialize(&config, &bus) ||
         !zoneEngine.Initialize(&config, &bus) ||
         !sessionEngine.Initialize(&config, &bus) ||
         !stateEngine.Initialize(&config, &bus) ||
         !volumeEngine.Initialize(&config, &bus) ||
         !orderFlowEngine.Initialize(&config, &bus) ||
         !featureEngine.Initialize(&config, &bus) ||
         !decisionEngine.Initialize(&config, &bus) ||
         !obEngine.Initialize(&config, &bus) ||
         !fvgEngine.Initialize(&config, &bus) ||
         !contextEngine.Initialize(&config, &bus))
      {
         CLogger::Error("GoldenPipeline", "Suite setup failed: Engine initialization error.");
         return false;
      }

      // 3. Process Multi-Tick Progression to trigger pipeline steps
      MqlTick tick;
      tick.time     = D'2026.08.06 12:00:00';
      tick.bid      = 1.1000;
      tick.ask      = 1.1002;
      tick.time_msc = 2000100;
      tick.volume   = 300; // Trigger high volume

      dataEngine.OnTick(tick);
      const SMarketDataSnapshot *marketSnap = dataEngine.GetSnapshot();

      // Pre-seed Swings to trigger structure & OB detectors
      SSwingPoint swingHigh; swingHigh.id = 1; swingHigh.price = 1.1050; swingHigh.type = SWING_TYPE_HIGH; swingHigh.time = tick.time - 200; swingHigh.timeframe = PERIOD_M5;
      SSwingPoint swingLow;  swingLow.id = 2; swingLow.price = 1.0950; swingLow.type = SWING_TYPE_LOW;  swingLow.time = tick.time - 100; swingLow.timeframe = PERIOD_M5;
      structureEngine.RegisterSwing(swingHigh);
      structureEngine.RegisterSwing(swingLow);

      // --- Execute Pipeline Pass ---
      
      // A. Structure
      structureEngine.ProcessStructure(*marketSnap);
      SStructureSnapshot structSnap = *structureEngine.GetSnapshot();
      // Inject BOS event
      structSnap.latestBOS.type = SWING_TYPE_HIGH;
      structSnap.latestBOS.price = 1.1050;
      structSnap.latestBOS.time = tick.time;

      // B. Liquidity
      liquidityEngine.ProcessLiquidity(*marketSnap, structSnap);
      const SLiquiditySnapshot *liqSnap = liquidityEngine.GetSnapshot();

      // C. Zones
      zoneEngine.ProcessZones(*marketSnap, structSnap, *liqSnap);
      const SZoneSnapshot *zoneSnap = zoneEngine.GetSnapshot();

      // Build intermediate Context for downstream modules
      contextEngine.UpdateContext(*marketSnap, structSnap, *liqSnap, *zoneSnap, 
                                  sessionEngine.GetSnapshot()[0], 
                                  stateEngine.GetSnapshot()[0], 
                                  volumeEngine.GetSnapshot()[0], 
                                  orderFlowEngine.GetSnapshot()[0],
                                  featureEngine.GetSnapshot()[0],
                                  decisionEngine.GetSnapshot()[0],
                                  obEngine.GetSnapshot()[0],
                                  fvgEngine.GetSnapshot()[0]);
      const SMarketContext *contextPass1 = contextEngine.GetContext();

      // D. Sessions
      sessionEngine.ProcessSession(*contextPass1);
      const SSessionSnapshot *sessionSnap = sessionEngine.GetSnapshot();

      // E. Market State
      stateEngine.ProcessState(*contextPass1);
      const SMarketStateSnapshot *stateSnap = stateEngine.GetSnapshot();

      // F. Volume
      volumeEngine.ProcessVolume(*contextPass1);
      const SVolumeSnapshot *volumeSnap = volumeEngine.GetSnapshot();

      // G. Order Flow Approximation
      orderFlowEngine.ProcessOrderFlow(*contextPass1);
      const SOrderFlowSnapshot *orderFlowSnap = orderFlowEngine.GetSnapshot();

      // Update intermediate Context
      contextEngine.UpdateContext(*marketSnap, structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, featureEngine.GetSnapshot()[0], decisionEngine.GetSnapshot()[0], obEngine.GetSnapshot()[0], fvgEngine.GetSnapshot()[0]);
      const SMarketContext *contextPass2 = contextEngine.GetContext();

      // H. Feature Engineering
      featureEngine.ProcessFeatures(*contextPass2);
      const SFeatureSnapshot *featuresSnap = featureEngine.GetSnapshot();

      // I. Decision Framework
      decisionEngine.ProcessDecision(*featuresSnap);
      const SDecisionSnapshot *decisionsSnap = decisionEngine.GetSnapshot();

      // J. Order Blocks
      contextEngine.UpdateContext(*marketSnap, structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, *featuresSnap, *decisionsSnap, obEngine.GetSnapshot()[0], fvgEngine.GetSnapshot()[0]);
      obEngine.ProcessOrderBlocks(*contextEngine.GetContext());
      const SOrderBlockSnapshot *obSnap = obEngine.GetSnapshot();

      // K. Fair Value Gaps
      fvgEngine.ProcessFVGs(*contextEngine.GetContext());
      const SFVGSnapshot *fvgSnap = fvgEngine.GetSnapshot();

      // L. Final Market Context
      contextEngine.UpdateContext(*marketSnap, structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, *featuresSnap, *decisionsSnap, *obSnap, *fvgSnap);
      const SMarketContext *finalContext = contextEngine.GetContext();

      // 4. Assert & Validate Integration Integrity
      bool pass = true;
      if(finalContext == NULL) pass = false;
      else
      {
         if(finalContext.contextId == 0) pass = false;
         if(finalContext.marketData.bid <= 0.0) pass = false;
         if(finalContext.structure.sequenceNumber == 0) pass = false;
         if(finalContext.session.sessionStats.periodTotalCandles < 0) pass = false;
         if(finalContext.features.sequenceNumber == 0) pass = false;
         if(finalContext.decisions.sequenceNumber == 0) pass = false;
         if(finalContext.orderBlocks.sequenceNumber == 0) pass = false;
         if(finalContext.fairValueGaps.sequenceNumber == 0) pass = false;
      }

      CLogger::Info("GoldenPipeline", StringFormat("Pipeline integrity check: %s", pass ? "PASSED" : "FAILED"));

      // 5. Shutdown Engines
      fvgEngine.Shutdown();
      obEngine.Shutdown();
      decisionEngine.Shutdown();
      featureEngine.Shutdown();
      orderFlowEngine.Shutdown();
      volumeEngine.Shutdown();
      stateEngine.Shutdown();
      sessionEngine.Shutdown();
      contextEngine.Shutdown();
      zoneEngine.Shutdown();
      liquidityEngine.Shutdown();
      structureEngine.Shutdown();
      dataEngine.Shutdown();

      CLogger::Flush();
      CLogger::Shutdown();

      PrintFormat("=== SENTINEL Golden Pipeline Test Result: %s ===", pass ? "PASSED" : "FAILED");
      return pass;
   }
};
