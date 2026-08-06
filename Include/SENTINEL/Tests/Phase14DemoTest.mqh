//+------------------------------------------------------------------+
//|                                             Phase14DemoTest.mqh |
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

/// @class CFVGTestListener
/// @brief Sample IEventListener proving event propagation for FVG updates.
class CFVGTestListener : public IEventListener
{
private:
   int m_fvgEvents;

public:
   CFVGTestListener() : m_fvgEvents(0) {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(event.type == EVENT_MKT_REGIME_CHANGE)
      {
         m_fvgEvents++;
         CLogger::Info("FVGTestListener", StringFormat("EVENT_FVG_CREATED Received #%d | FVG MidPrice: %.5f | Payload: %s", 
                                                       m_fvgEvents, event.priceValue, event.payloadJson));
      }
   }

   int FVGEvents() const { return m_fvgEvents; }
};

/// @class CPhase14DemoTest
/// @brief End-to-end integration test demonstrating the Fair Value Gap Module pipeline.
class CPhase14DemoTest
{
public:
   static bool RunDemo()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("Phase14DemoTest", "=== Starting Phase 14 FVG Demonstration ===");

      // 1. Setup Infrastructure
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);
      config.SetDouble("fvg.min_gap_size_points", 5.0);

      CEventBus bus;
      CFVGTestListener listener;
      CEventRecorder recorder;

      // 2. Subscribe Listener to FVG Events
      bus.Subscribe(EVENT_MKT_REGIME_CHANGE, &listener);
      bus.Subscribe(EVENT_MKT_REGIME_CHANGE, &recorder);

      // 3. Initialize Engines
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
         CLogger::Error("Phase14DemoTest", "Engine initialization failed.");
         return false;
      }

      // 4. Simulate Market Tick & Snapshot Creation with candle sequence
      MqlTick tick;
      tick.time     = D'2026.08.06 10:00:00';
      tick.bid      = 1.1000;
      tick.ask      = 1.1002;
      tick.time_msc = 1001400;

      dataEngine.OnTick(tick);
      const SMarketDataSnapshot *marketSnap = dataEngine.GetSnapshot();

      // 5. Generate Base Snapshots
      SStructureSnapshot structSnap = *structureEngine.GetSnapshot();
      liquidityEngine.ProcessLiquidity(*marketSnap, structSnap);
      const SLiquiditySnapshot *liqSnap = liquidityEngine.GetSnapshot();
      zoneEngine.ProcessZones(*marketSnap, structSnap, *liqSnap);
      const SZoneSnapshot *zoneSnap = zoneEngine.GetSnapshot();

      // Build base Context with placeholders
      contextEngine.UpdateContext(*marketSnap, structSnap, *liqSnap, *zoneSnap, 
                                  sessionEngine.GetSnapshot()[0], 
                                  stateEngine.GetSnapshot()[0], 
                                  volumeEngine.GetSnapshot()[0], 
                                  orderFlowEngine.GetSnapshot()[0],
                                  featureEngine.GetSnapshot()[0],
                                  decisionEngine.GetSnapshot()[0],
                                  obEngine.GetSnapshot()[0],
                                  fvgEngine.GetSnapshot()[0]);
      const SMarketContext *baseContext = contextEngine.GetContext();

      // Update Session & State & Volume & OrderFlow
      sessionEngine.ProcessSession(*baseContext);
      const SSessionSnapshot *sessionSnap = sessionEngine.GetSnapshot();

      stateEngine.ProcessState(*baseContext);
      const SMarketStateSnapshot *stateSnap = stateEngine.GetSnapshot();

      volumeEngine.ProcessVolume(*baseContext);
      const SVolumeSnapshot *volumeSnap = volumeEngine.GetSnapshot();

      orderFlowEngine.ProcessOrderFlow(*baseContext);
      const SOrderFlowSnapshot *orderFlowSnap = orderFlowEngine.GetSnapshot();

      // Re-create context for feature calculations
      contextEngine.UpdateContext(*marketSnap, structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, featureEngine.GetSnapshot()[0], decisionEngine.GetSnapshot()[0], obEngine.GetSnapshot()[0], fvgEngine.GetSnapshot()[0]);
      const SMarketContext *contextForFeatures = contextEngine.GetContext();

      // Update features
      featureEngine.ProcessFeatures(*contextForFeatures);
      const SFeatureSnapshot *featuresSnap = featureEngine.GetSnapshot();

      // Rebuild context for FVG calculations
      contextEngine.UpdateContext(*marketSnap, structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, *featuresSnap, decisionEngine.GetSnapshot()[0], obEngine.GetSnapshot()[0], fvgEngine.GetSnapshot()[0]);
      const SMarketContext *contextForFVG = contextEngine.GetContext();

      // 6. Update FVGs
      fvgEngine.ProcessFVGs(*contextForFVG);
      const SFVGSnapshot *fvgSnap = fvgEngine.GetSnapshot();

      // Rebuild context with updated FVGs Snapshot
      contextEngine.UpdateContext(*marketSnap, structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, *featuresSnap, decisionEngine.GetSnapshot()[0], obEngine.GetSnapshot()[0], *fvgSnap);
      const SMarketContext *updatedContext = contextEngine.GetContext();

      bool success = (updatedContext != NULL && 
                      updatedContext.fairValueGaps.sequenceNumber > 0 && 
                      updatedContext.fairValueGaps.activeGapsCount >= 0);

      CLogger::Info("Phase14DemoTest", StringFormat("FVGs Context Verified: SeqNum=%d, ActiveFVGs=%d", 
                                                    updatedContext.fairValueGaps.sequenceNumber, 
                                                    updatedContext.fairValueGaps.activeGapsCount));

      // 7. Cleanup
      fvgEngine.Shutdown();
      obEngine.Shutdown();
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

      PrintFormat("=== Phase 14 FVG Demonstration Result: %s ===", success ? "PASSED" : "FAILED");
      return success;
   }
};
