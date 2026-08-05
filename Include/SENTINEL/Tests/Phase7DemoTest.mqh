//+------------------------------------------------------------------+
//|                                             Phase7DemoTest.mqh |
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
#include "../Framework/Context/ContextEngine.mqh"
#include "../Logging/Logger.mqh"

/// @class CSessionTestListener
/// @brief Sample IEventListener proving event propagation for trading session updates.
class CSessionTestListener : public IEventListener
{
private:
   int m_sessionChangeEvents;

public:
   CSessionTestListener() : m_sessionChangeEvents(0) {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(event.type == EVENT_MKT_SESSION_CHANGE)
      {
         m_sessionChangeEvents++;
         CLogger::Info("SessionTestListener", StringFormat("EVENT_MKT_SESSION_CHANGE Received #%d | Active Session ID: %d", 
                                                           m_sessionChangeEvents, event.entityId));
      }
   }

   int SessionChangeEvents() const { return m_sessionChangeEvents; }
};

/// @class CPhase7DemoTest
/// @brief End-to-end demonstration for Phase 7 Session Engine.
/// Pipeline: MT5 Tick -> DataEngine -> MarketDataSnapshot -> StructureEngine -> StructureSnapshot -> LiquidityEngine -> LiquiditySnapshot -> ZoneEngine -> ZoneSnapshot -> ContextEngine -> MarketContext -> SessionEngine -> SessionSnapshot -> ContextEngine -> Updated MarketContext -> EventBus -> Listener -> CLogger.
class CPhase7DemoTest
{
public:
   static bool RunDemo()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("Phase7DemoTest", "=== Starting Phase 7 Session Engine Demonstration ===");

      // 1. Setup Infrastructure
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);
      config.SetInt("session.broker_offset_hours", 2);

      CEventBus bus;
      CSessionTestListener listener;
      CEventRecorder recorder;

      // 2. Subscribe Listener & Recorder to Session Events
      bus.Subscribe(EVENT_MKT_SESSION_CHANGE, &listener);
      bus.Subscribe(EVENT_MKT_SESSION_CHANGE, &recorder);

      // 3. Initialize Core Engines
      CDataEngine dataEngine;
      CStructureEngine structureEngine;
      CLiquidityEngine liquidityEngine(3.0);
      CZoneEngine zoneEngine;
      CContextEngine contextEngine;
      CSessionEngine sessionEngine;

      if(!dataEngine.Initialize(&config, &bus) || 
         !structureEngine.Initialize(&config, &bus) || 
         !liquidityEngine.Initialize(&config, &bus) ||
         !zoneEngine.Initialize(&config, &bus) ||
         !contextEngine.Initialize(&config, &bus) ||
         !sessionEngine.Initialize(&config, &bus))
      {
         CLogger::Error("Phase7DemoTest", "Engine initialization failed.");
         return false;
      }

      // 4. Simulate Market Tick & Snapshot Creation (Hour 14 represents London/NY Overlap)
      MqlTick tick;
      tick.time     = D'2026.08.05 14:30:00';
      tick.bid      = 1.1000;
      tick.ask      = 1.1002;
      tick.time_msc = 1000950;

      dataEngine.OnTick(tick);
      const SMarketDataSnapshot *marketSnap = dataEngine.GetSnapshot();

      // 5. Generate Structure, Liquidity & Zone Snapshots
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

      // 6. Build base MarketContext
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, sessionEngine.GetSnapshot()[0]);
      const SMarketContext *baseContext = contextEngine.GetContext();

      // 7. Update Session Engine and then rebuild context with updated Session Snapshot
      sessionEngine.ProcessSession(*baseContext);
      const SSessionSnapshot *sessionSnap = sessionEngine.GetSnapshot();

      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, *sessionSnap);
      const SMarketContext *updatedContext = contextEngine.GetContext();

      bool success = (updatedContext != NULL && 
                      updatedContext.session.currentSession == SESSION_OVERLAP_LDN_NY && 
                      updatedContext.session.stats.openPrice == 1.1000);

      CLogger::Info("Phase7DemoTest", StringFormat("Session Context Verified: SeqNum=%d, Session=%d, OpenPrice=%.5f, DailyOpen=%.5f", 
                                                    updatedContext.session.sequenceNumber, 
                                                    updatedContext.session.currentSession, 
                                                    updatedContext.session.stats.openPrice,
                                                    updatedContext.session.referenceLevels.currentDayOpen));

      // 8. Cleanup
      sessionEngine.Shutdown();
      contextEngine.Shutdown();
      zoneEngine.Shutdown();
      liquidityEngine.Shutdown();
      structureEngine.Shutdown();
      dataEngine.Shutdown();
      CLogger::Flush();
      CLogger::Shutdown();

      PrintFormat("=== Phase 7 Session Engine Demonstration Result: %s ===", success ? "PASSED" : "FAILED");
      return success;
   }
};
