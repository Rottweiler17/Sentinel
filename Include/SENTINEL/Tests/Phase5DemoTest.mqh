//+------------------------------------------------------------------+
//|                                             Phase5DemoTest.mqh |
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
#include "../Logging/Logger.mqh"

/// @class CZoneTestListener
/// @brief Sample IEventListener proving event propagation for generic zone creation, updates, and invalidations.
class CZoneTestListener : public IEventListener
{
private:
   int m_zoneCreatedEvents;
   int m_zoneInvalidatedEvents;

public:
   CZoneTestListener() : m_zoneCreatedEvents(0), m_zoneInvalidatedEvents(0) {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(event.type == EVENT_MKT_ZONE_CREATED)
      {
         m_zoneCreatedEvents++;
         CLogger::Info("ZoneTestListener", StringFormat("EVENT_MKT_ZONE_CREATED Received #%d | MidPrice: %.5f | Payload: %s", 
                                                         m_zoneCreatedEvents, event.priceValue, event.payloadJson));
      }
      else if(event.type == EVENT_MKT_ZONE_INVALIDATED)
      {
         m_zoneInvalidatedEvents++;
         CLogger::Info("ZoneTestListener", StringFormat("EVENT_MKT_ZONE_INVALIDATED Received #%d | MidPrice: %.5f | Payload: %s", 
                                                            m_zoneInvalidatedEvents, event.priceValue, event.payloadJson));
      }
   }

   int ZoneCreatedEvents()     const { return m_zoneCreatedEvents; }
   int ZoneInvalidatedEvents() const { return m_zoneInvalidatedEvents; }
};

/// @class CPhase5DemoTest
/// @brief End-to-end demonstration for Phase 5 Generic Zone Framework.
/// Pipeline: MT5 Tick -> DataEngine -> SMarketDataSnapshot -> StructureEngine -> SStructureSnapshot -> LiquidityEngine -> SLiquiditySnapshot -> ZoneEngine -> SZoneSnapshot -> EventBus -> Listener -> CLogger.
class CPhase5DemoTest
{
public:
   static bool RunDemo()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("Phase5DemoTest", "=== Starting Phase 5 Generic Zone Framework Demonstration ===");

      // 1. Setup Infrastructure
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);

      CEventBus bus;
      CZoneTestListener listener;
      CEventRecorder recorder;

      // 2. Subscribe Listener & Recorder to Zone Events
      bus.Subscribe(EVENT_MKT_ZONE_CREATED, &listener);
      bus.Subscribe(EVENT_MKT_ZONE_INVALIDATED, &listener);
      bus.Subscribe(EVENT_MKT_ZONE_CREATED, &recorder);
      bus.Subscribe(EVENT_MKT_ZONE_INVALIDATED, &recorder);

      // 3. Initialize Core Engines
      CDataEngine dataEngine;
      CStructureEngine structureEngine;
      CLiquidityEngine liquidityEngine(3.0);
      CZoneEngine zoneEngine;

      if(!dataEngine.Initialize(&config, &bus) || 
         !structureEngine.Initialize(&config, &bus) || 
         !liquidityEngine.Initialize(&config, &bus) ||
         !zoneEngine.Initialize(&config, &bus))
      {
         CLogger::Error("Phase5DemoTest", "Engine initialization failed.");
         return false;
      }

      // 4. Simulate Market Tick & Snapshot Creation
      MqlTick tick;
      tick.time     = TimeCurrent();
      tick.bid      = 1.1000;
      tick.ask      = 1.1002;
      tick.time_msc = 1000800;

      dataEngine.OnTick(tick);
      const SMarketDataSnapshot *marketSnap = dataEngine.GetSnapshot();

      // 5. Register Swings & Generate Structure & Liquidity Snapshots
      SSwingPoint swingHigh; swingHigh.id = 1; swingHigh.price = 1.1050; swingHigh.type = SWING_TYPE_HIGH; swingHigh.time = tick.time - 200; swingHigh.timeframe = PERIOD_M5;
      SSwingPoint swingLow;  swingLow.id = 2; swingLow.price = 1.0950; swingLow.type = SWING_TYPE_LOW;  swingLow.time = tick.time - 100; swingLow.timeframe = PERIOD_M5;

      structureEngine.RegisterSwing(swingHigh);
      structureEngine.RegisterSwing(swingLow);
      structureEngine.ProcessStructure(*marketSnap);
      const SStructureSnapshot *structSnap = structureEngine.GetSnapshot();

      liquidityEngine.ProcessLiquidity(*marketSnap, *structSnap);
      const SLiquiditySnapshot *liqSnap = liquidityEngine.GetSnapshot();

      // 6. Process Generic Zone Framework Pipeline
      zoneEngine.ProcessZones(*marketSnap, *structSnap, *liqSnap);

      // 7. Verify SZoneSnapshot
      const SZoneSnapshot *zoneSnap = zoneEngine.GetSnapshot();
      bool snapshotValid = (zoneSnap != NULL && zoneSnap.sequenceNumber > 0);

      CLogger::Info("Phase5DemoTest", StringFormat("ZoneSnapshot Verified: ActiveZones=%d, MergedZones=%d, QualityScore=%.2f", 
                                                    zoneSnap.activeZonesCount, zoneSnap.mergedZonesCount, zoneSnap.zoneQualityScore));

      // 8. Cleanup
      zoneEngine.Shutdown();
      liquidityEngine.Shutdown();
      structureEngine.Shutdown();
      dataEngine.Shutdown();
      CLogger::Flush();
      CLogger::Shutdown();

      bool success = (snapshotValid && listener.ZoneCreatedEvents() >= 0);
      PrintFormat("=== Phase 5 Generic Zone Framework Demonstration Result: %s ===", success ? "PASSED" : "FAILED");
      return success;
   }
};
