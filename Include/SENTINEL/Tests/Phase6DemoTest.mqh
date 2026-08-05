//+------------------------------------------------------------------+
//|                                             Phase6DemoTest.mqh |
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
#include "../Framework/Context/ContextEngine.mqh"
#include "../Logging/Logger.mqh"

/// @class CContextTestListener
/// @brief Sample IEventListener proving event propagation for unified market context creation.
class CContextTestListener : public IEventListener
{
private:
   int m_contextCreatedEvents;

public:
   CContextTestListener() : m_contextCreatedEvents(0) {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(event.type == EVENT_SYS_INIT)
      {
         m_contextCreatedEvents++;
         CLogger::Info("ContextTestListener", StringFormat("EVENT_CONTEXT_CREATED Received #%d | Bid: %.5f | Payload: %s", 
                                                           m_contextCreatedEvents, event.priceValue, event.payloadJson));
      }
   }

   int ContextCreatedEvents() const { return m_contextCreatedEvents; }
};

/// @class CPhase6DemoTest
/// @brief End-to-end demonstration for Phase 6 Unified Context Framework.
/// Pipeline: MT5 Tick -> DataEngine -> MarketDataSnapshot -> StructureEngine -> StructureSnapshot -> LiquidityEngine -> LiquiditySnapshot -> ZoneEngine -> ZoneSnapshot -> ContextEngine -> MarketContext -> EventBus -> Listener -> CLogger.
class CPhase6DemoTest
{
public:
   static bool RunDemo()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("Phase6DemoTest", "=== Starting Phase 6 Unified Context Framework Demonstration ===");

      // 1. Setup Infrastructure
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);

      CEventBus bus;
      CContextTestListener listener;
      CEventRecorder recorder;

      // 2. Subscribe Listener & Recorder to Context Events
      bus.Subscribe(EVENT_SYS_INIT, &listener);
      bus.Subscribe(EVENT_SYS_INIT, &recorder);

      // 3. Initialize Core Engines
      CDataEngine dataEngine;
      CStructureEngine structureEngine;
      CLiquidityEngine liquidityEngine(3.0);
      CZoneEngine zoneEngine;
      CContextEngine contextEngine;

      if(!dataEngine.Initialize(&config, &bus) || 
         !structureEngine.Initialize(&config, &bus) || 
         !liquidityEngine.Initialize(&config, &bus) ||
         !zoneEngine.Initialize(&config, &bus) ||
         !contextEngine.Initialize(&config, &bus))
      {
         CLogger::Error("Phase6DemoTest", "Engine initialization failed.");
         return false;
      }

      // 4. Simulate Market Tick & Snapshot Creation
      MqlTick tick;
      tick.time     = TimeCurrent();
      tick.bid      = 1.1000;
      tick.ask      = 1.1002;
      tick.time_msc = 1000900;

      dataEngine.OnTick(tick);
      const SMarketDataSnapshot *marketSnap = dataEngine.GetSnapshot();

      // 5. Register Swings & Generate Structure, Liquidity & Zone Snapshots
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

      // 6. Update Unified Market Context
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap);

      // 7. Verify SMarketContext
      const SMarketContext *context = contextEngine.GetContext();
      bool contextValid = (context != NULL && context.sequenceNumber > 0 && context.marketData.bid == 1.1000);

      CLogger::Info("Phase6DemoTest", StringFormat("MarketContext Verified: SeqNum=%d, Bid=%.5f, ActiveZones=%d, LiquidityScore=%.2f", 
                                                    context.sequenceNumber, context.marketData.bid, context.zones.activeZonesCount, context.liquidity.liquidityQualityScore));

      // 8. Cleanup
      contextEngine.Shutdown();
      zoneEngine.Shutdown();
      liquidityEngine.Shutdown();
      structureEngine.Shutdown();
      dataEngine.Shutdown();
      CLogger::Flush();
      CLogger::Shutdown();

      bool success = (contextValid && listener.ContextCreatedEvents() >= 0);
      PrintFormat("=== Phase 6 Unified Context Demonstration Result: %s ===", success ? "PASSED" : "FAILED");
      return success;
   }
};
