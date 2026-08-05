//+------------------------------------------------------------------+
//|                                            Phase10DemoTest.mqh |
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
#include "../Framework/Context/ContextEngine.mqh"
#include "../Logging/Logger.mqh"

/// @class COrderFlowTestListener
/// @brief Sample IEventListener proving event propagation for estimated order flow updates.
class COrderFlowTestListener : public IEventListener
{
private:
   int m_orderFlowEvents;

public:
   COrderFlowTestListener() : m_orderFlowEvents(0) {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(event.type == EVENT_MKT_VOLUME_PROFILE && event.entityId == 10)
      {
         m_orderFlowEvents++;
         CLogger::Info("OrderFlowTestListener", StringFormat("EVENT_ORDERFLOW_UPDATED Received #%d | Estimated Buying Pressure: %.2f%% | Payload: %s", 
                                                             m_orderFlowEvents, event.priceValue, event.payloadJson));
      }
   }

   int OrderFlowEvents() const { return m_orderFlowEvents; }
};

/// @class CPhase10DemoTest
/// @brief End-to-end demonstration for Phase 10 Order Flow Approximation Framework.
/// Pipeline: MarketContext -> OrderFlowEngine -> OrderFlowSnapshot -> Updated MarketContext -> EventBus -> Listener.
class CPhase10DemoTest
{
public:
   static bool RunDemo()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("Phase10DemoTest", "=== Starting Phase 10 Order Flow Approximation Demonstration ===");

      // 1. Setup Infrastructure
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);
      config.SetDouble("orderflow.aggression_threshold", 1.2);

      CEventBus bus;
      COrderFlowTestListener listener;
      CEventRecorder recorder;

      // 2. Subscribe Listener & Recorder to Order Flow Events
      bus.Subscribe(EVENT_MKT_VOLUME_PROFILE, &listener);
      bus.Subscribe(EVENT_MKT_VOLUME_PROFILE, &recorder);

      // 3. Initialize Engines
      CDataEngine dataEngine;
      CStructureEngine structureEngine;
      CLiquidityEngine liquidityEngine(3.0);
      CZoneEngine zoneEngine;
      CSessionEngine sessionEngine;
      CMarketStateEngine stateEngine;
      CVolumeEngine volumeEngine;
      COrderFlowEngine orderFlowEngine;
      CContextEngine contextEngine;

      if(!dataEngine.Initialize(&config, &bus) || 
         !structureEngine.Initialize(&config, &bus) || 
         !liquidityEngine.Initialize(&config, &bus) ||
         !zoneEngine.Initialize(&config, &bus) ||
         !sessionEngine.Initialize(&config, &bus) ||
         !stateEngine.Initialize(&config, &bus) ||
         !volumeEngine.Initialize(&config, &bus) ||
         !orderFlowEngine.Initialize(&config, &bus) ||
         !contextEngine.Initialize(&config, &bus))
      {
         CLogger::Error("Phase10DemoTest", "Engine initialization failed.");
         return false;
      }

      // 4. Simulate Market Tick & Snapshot Creation
      MqlTick tick;
      tick.time     = TimeCurrent();
      tick.bid      = 1.1000;
      tick.ask      = 1.1002;
      tick.time_msc = 1001050;
      tick.volume   = 80;

      dataEngine.OnTick(tick);
      const SMarketDataSnapshot *marketSnap = dataEngine.GetSnapshot();

      // 5. Generate Base Snapshots
      SSwingPoint swingHigh; swingHigh.id = 1; swingHigh.price = 1.1050; swingHigh.type = SWING_TYPE_HIGH; swingHigh.time = tick.time - 200; swingHigh.timeframe = PERIOD_M5;
      SSwingPoint swingLow;  swingLow.id = 2; swingLow.price = 1.0950; swingLow.type = SWING_TYPE_LOW;  swingLow.time = tick.time - 100; swingLow.timeframe = PERIOD_M5;

      structureEngine.RegisterSwing(swingHigh);
      structureEngine.RegisterSwing(swingLow);
      structureEngine.ProcessStructure(*marketSnap);
      const SStructureSnapshot *structSnap = structureEngine.GetSnapshot();

      liquidityEngine.ProcessLiquidity(*marketSnap, *structSnap);
      const SLiquiditySnapshot *liqSnap = liquidityEngine.GetSnapshot();

      zoneEngine.ProcessZones(*marketSnap, *structSnap, *liqSnap);
      const SZoneSnapshot *zoneSnap = zoneEngine.GetSnapshot();

      // Build base Context with placeholder values
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, 
                                  sessionEngine.GetSnapshot()[0], 
                                  stateEngine.GetSnapshot()[0], 
                                  volumeEngine.GetSnapshot()[0], 
                                  orderFlowEngine.GetSnapshot()[0]);
      const SMarketContext *baseContext = contextEngine.GetContext();

      // Update Session & State & Volume
      sessionEngine.ProcessSession(*baseContext);
      const SSessionSnapshot *sessionSnap = sessionEngine.GetSnapshot();

      stateEngine.ProcessState(*baseContext);
      const SMarketStateSnapshot *stateSnap = stateEngine.GetSnapshot();

      volumeEngine.ProcessVolume(*baseContext);
      const SVolumeSnapshot *volumeSnap = volumeEngine.GetSnapshot();

      // 6. Update Order Flow calculations
      orderFlowEngine.ProcessOrderFlow(*baseContext);
      const SOrderFlowSnapshot *orderFlowSnap = orderFlowEngine.GetSnapshot();

      // Rebuild context with updated Order Flow Snapshot
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap);
      const SMarketContext *updatedContext = contextEngine.GetContext();

      bool success = (updatedContext != NULL && 
                      updatedContext.orderFlow.sequenceNumber > 0 && 
                      updatedContext.orderFlow.buyingPressure > 0.0);

      CLogger::Info("Phase10DemoTest", StringFormat("OrderFlow Context Verified: SeqNum=%d, BuyPress=%.2f%%, SellPress=%.2f%%, Balance=%.2f, Init=%d, Abs=%d", 
                                                    updatedContext.orderFlow.sequenceNumber, 
                                                    updatedContext.orderFlow.buyingPressure, 
                                                    updatedContext.orderFlow.sellingPressure,
                                                    updatedContext.orderFlow.pressureBalance,
                                                    updatedContext.orderFlow.initiative,
                                                    updatedContext.orderFlow.absorptionEstimate));

      // 7. Cleanup
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

      PrintFormat("=== Phase 10 Order Flow Demonstration Result: %s ===", success ? "PASSED" : "FAILED");
      return success;
   }
};
