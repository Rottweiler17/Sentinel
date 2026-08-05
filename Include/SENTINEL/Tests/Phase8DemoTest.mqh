//+------------------------------------------------------------------+
//|                                             Phase8DemoTest.mqh |
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
#include "../Framework/Context/ContextEngine.mqh"
#include "../Logging/Logger.mqh"

/// @class CMarketStateTestListener
/// @brief Sample IEventListener proving event propagation for market state classification transitions.
class CMarketStateTestListener : public IEventListener
{
private:
   int m_stateChangeEvents;

public:
   CMarketStateTestListener() : m_stateChangeEvents(0) {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(event.type == EVENT_MKT_REGIME_CHANGE)
      {
         m_stateChangeEvents++;
         CLogger::Info("MarketStateTestListener", StringFormat("EVENT_MARKET_STATE_CHANGED Received #%d | State Code: %d", 
                                                               m_stateChangeEvents, event.entityId));
      }
   }

   int StateChangeEvents() const { return m_stateChangeEvents; }
};

/// @class CPhase8DemoTest
/// @brief End-to-end demonstration for Phase 8 Market State Engine.
/// Pipeline: MarketContext -> MarketStateEngine -> MarketStateSnapshot -> Updated MarketContext -> EventBus -> Listener.
class CPhase8DemoTest
{
public:
   static bool RunDemo()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("Phase8DemoTest", "=== Starting Phase 8 Market State Engine Demonstration ===");

      // 1. Setup Infrastructure
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);

      CEventBus bus;
      CMarketStateTestListener listener;
      CEventRecorder recorder;

      // 2. Subscribe Listener & Recorder to State Events
      bus.Subscribe(EVENT_MKT_REGIME_CHANGE, &listener);
      bus.Subscribe(EVENT_MKT_REGIME_CHANGE, &recorder);

      // 3. Initialize Engines
      CDataEngine dataEngine;
      CStructureEngine structureEngine;
      CLiquidityEngine liquidityEngine(3.0);
      CZoneEngine zoneEngine;
      CSessionEngine sessionEngine;
      CMarketStateEngine stateEngine;
      CContextEngine contextEngine;

      if(!dataEngine.Initialize(&config, &bus) || 
         !structureEngine.Initialize(&config, &bus) || 
         !liquidityEngine.Initialize(&config, &bus) ||
         !zoneEngine.Initialize(&config, &bus) ||
         !sessionEngine.Initialize(&config, &bus) ||
         !stateEngine.Initialize(&config, &bus) ||
         !contextEngine.Initialize(&config, &bus))
      {
         CLogger::Error("Phase8DemoTest", "Engine initialization failed.");
         return false;
      }

      // 4. Simulate Market Tick & Snapshot Creation
      MqlTick tick;
      tick.time     = TimeCurrent();
      tick.bid      = 1.1000;
      tick.ask      = 1.1002;
      tick.time_msc = 1000990;

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

      // Build base Context
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, sessionEngine.GetSnapshot()[0], stateEngine.GetSnapshot()[0]);
      const SMarketContext *baseContext = contextEngine.GetContext();

      // Update Session
      sessionEngine.ProcessSession(*baseContext);
      const SSessionSnapshot *sessionSnap = sessionEngine.GetSnapshot();

      // 6. Update Market State
      stateEngine.ProcessState(*baseContext);
      const SMarketStateSnapshot *stateSnap = stateEngine.GetSnapshot();

      // Rebuild context with updated state
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap);
      const SMarketContext *updatedContext = contextEngine.GetContext();

      bool success = (updatedContext != NULL && 
                      updatedContext.state.sequenceNumber > 0 && 
                      updatedContext.state.currentState != STATE_ENV_UNKNOWN);

      CLogger::Info("Phase8DemoTest", StringFormat("State Context Verified: SeqNum=%d, CurrentState=%d, VolatilityRating=%d, TrendRating=%.2f", 
                                                    updatedContext.state.sequenceNumber, 
                                                    updatedContext.state.currentState, 
                                                    updatedContext.state.volatilityRating,
                                                    updatedContext.state.trendRating));

      // 7. Cleanup
      stateEngine.Shutdown();
      sessionEngine.Shutdown();
      contextEngine.Shutdown();
      zoneEngine.Shutdown();
      liquidityEngine.Shutdown();
      structureEngine.Shutdown();
      dataEngine.Shutdown();
      CLogger::Flush();
      CLogger::Shutdown();

      PrintFormat("=== Phase 8 Market State Demonstration Result: %s ===", success ? "PASSED" : "FAILED");
      return success;
   }
};
