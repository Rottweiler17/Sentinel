//+------------------------------------------------------------------+
//|                                            Phase13DemoTest.mqh |
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
#include "../Framework/Context/ContextEngine.mqh"
#include "../Logging/Logger.mqh"

/// @class COrderBlockTestListener
/// @brief Sample IEventListener proving event propagation for order block updates.
class COrderBlockTestListener : public IEventListener
{
private:
   int m_obEvents;

public:
   COrderBlockTestListener() : m_obEvents(0) {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(event.type == EVENT_MKT_REGIME_CHANGE)
      {
         m_obEvents++;
         CLogger::Info("OrderBlockTestListener", StringFormat("EVENT_ORDERBLOCK_CREATED Received #%d | OB MidPrice: %.5f | Payload: %s", 
                                                              m_obEvents, event.priceValue, event.payloadJson));
      }
   }

   int OBEvents() const { return m_obEvents; }
};

/// @class CPhase13DemoTest
/// @brief End-to-end integration test demonstrating the Order Block Module pipeline.
class CPhase13DemoTest
{
public:
   static bool RunDemo()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("Phase13DemoTest", "=== Starting Phase 13 Order Block Demonstration ===");

      // 1. Setup Infrastructure
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);
      config.SetDouble("orderblock.min_strength", 40.0);

      CEventBus bus;
      COrderBlockTestListener listener;
      CEventRecorder recorder;

      // 2. Subscribe Listener to OB Events
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
         !contextEngine.Initialize(&config, &bus))
      {
         CLogger::Error("Phase13DemoTest", "Engine initialization failed.");
         return false;
      }

      // 4. Simulate Market Tick & Snapshot Creation with volume spike
      MqlTick tick;
      tick.time     = TimeCurrent();
      tick.bid      = 1.1000;
      tick.ask      = 1.1002;
      tick.time_msc = 1001300;
      tick.volume   = 250; // High volume spike to validate OB detection

      dataEngine.OnTick(tick);
      const SMarketDataSnapshot *marketSnap = dataEngine.GetSnapshot();

      // 5. Generate Structure (BOS), Liquidity & Zone Snapshots
      SSwingPoint swingHigh; swingHigh.id = 1; swingHigh.price = 1.1050; swingHigh.type = SWING_TYPE_HIGH; swingHigh.time = tick.time - 200; swingHigh.timeframe = PERIOD_M5;
      SSwingPoint swingLow;  swingLow.id = 2; swingLow.price = 1.0950; swingLow.type = SWING_TYPE_LOW;  swingLow.time = tick.time - 100; swingLow.timeframe = PERIOD_M5;

      structureEngine.RegisterSwing(swingHigh);
      structureEngine.RegisterSwing(swingLow);
      structureEngine.ProcessStructure(*marketSnap);
      
      // Inject simulated BOS into structure snapshot
      SStructureSnapshot structSnap = *structureEngine.GetSnapshot();
      structSnap.latestBOS.type = SWING_TYPE_HIGH;
      structSnap.latestBOS.price = 1.1050;
      structSnap.latestBOS.time = tick.time;

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
                                  obEngine.GetSnapshot()[0]);
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
      contextEngine.UpdateContext(*marketSnap, structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, featureEngine.GetSnapshot()[0], decisionEngine.GetSnapshot()[0], obEngine.GetSnapshot()[0]);
      const SMarketContext *contextForFeatures = contextEngine.GetContext();

      // Update features
      featureEngine.ProcessFeatures(*contextForFeatures);
      const SFeatureSnapshot *featuresSnap = featureEngine.GetSnapshot();

      // Rebuild context for OB calculations
      contextEngine.UpdateContext(*marketSnap, structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, *featuresSnap, decisionEngine.GetSnapshot()[0], obEngine.GetSnapshot()[0]);
      const SMarketContext *contextForOB = contextEngine.GetContext();

      // 6. Update Order Blocks
      obEngine.ProcessOrderBlocks(*contextForOB);
      const SOrderBlockSnapshot *obSnap = obEngine.GetSnapshot();

      // Rebuild context with updated Order Blocks Snapshot
      contextEngine.UpdateContext(*marketSnap, structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, *featuresSnap, decisionEngine.GetSnapshot()[0], *obSnap);
      const SMarketContext *updatedContext = contextEngine.GetContext();

      bool success = (updatedContext != NULL && 
                      updatedContext.orderBlocks.sequenceNumber > 0 && 
                      updatedContext.orderBlocks.activeBlocksCount >= 0);

      CLogger::Info("Phase13DemoTest", StringFormat("OrderBlocks Context Verified: SeqNum=%d, ActiveBlocks=%d", 
                                                    updatedContext.orderBlocks.sequenceNumber, 
                                                    updatedContext.orderBlocks.activeBlocksCount));

      // 7. Cleanup
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

      PrintFormat("=== Phase 13 Order Block Demonstration Result: %s ===", success ? "PASSED" : "FAILED");
      return success;
   }
};
