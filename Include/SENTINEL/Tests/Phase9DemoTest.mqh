//+------------------------------------------------------------------+
//|                                             Phase9DemoTest.mqh |
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
#include "../Framework/Context/ContextEngine.mqh"
#include "../Logging/Logger.mqh"

/// @class CVolumeTestListener
/// @brief Sample IEventListener proving event propagation for volume profile / spike updates.
class CVolumeTestListener : public IEventListener
{
private:
   int m_volumeEvents;

public:
   CVolumeTestListener() : m_volumeEvents(0) {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(event.type == EVENT_MKT_VOLUME_PROFILE)
      {
         m_volumeEvents++;
         CLogger::Info("VolumeTestListener", StringFormat("EVENT_VOLUME_UPDATED Received #%d | VolState Code: %d | PriceValue: %.2f", 
                                                           m_volumeEvents, event.entityId, event.priceValue));
      }
   }

   int VolumeEvents() const { return m_volumeEvents; }
};

/// @class CPhase9DemoTest
/// @brief End-to-end demonstration for Phase 9 Volume Framework.
/// Pipeline: MarketContext -> VolumeEngine -> VolumeSnapshot -> Updated MarketContext -> EventBus -> Listener.
class CPhase9DemoTest
{
public:
   static bool RunDemo()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("Phase9DemoTest", "=== Starting Phase 9 Volume Framework Demonstration ===");

      // 1. Setup Infrastructure
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);
      config.SetInt("volume.rolling_average_period", 5);
      config.SetDouble("volume.spike_multiplier", 1.5);

      CEventBus bus;
      CVolumeTestListener listener;
      CEventRecorder recorder;

      // 2. Subscribe Listener & Recorder to Volume Events
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
      CContextEngine contextEngine;

      if(!dataEngine.Initialize(&config, &bus) || 
         !structureEngine.Initialize(&config, &bus) || 
         !liquidityEngine.Initialize(&config, &bus) ||
         !zoneEngine.Initialize(&config, &bus) ||
         !sessionEngine.Initialize(&config, &bus) ||
         !stateEngine.Initialize(&config, &bus) ||
         !volumeEngine.Initialize(&config, &bus) ||
         !contextEngine.Initialize(&config, &bus))
      {
         CLogger::Error("Phase9DemoTest", "Engine initialization failed.");
         return false;
      }

      // 4. Simulate Market Tick & Snapshot Creation
      MqlTick tick;
      tick.time     = TimeCurrent();
      tick.bid      = 1.1000;
      tick.ask      = 1.1002;
      tick.time_msc = 1001000;
      tick.volume   = 100; // Simulated high volume

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
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, sessionEngine.GetSnapshot()[0], stateEngine.GetSnapshot()[0], volumeEngine.GetSnapshot()[0]);
      const SMarketContext *baseContext = contextEngine.GetContext();

      // Update Session & State
      sessionEngine.ProcessSession(*baseContext);
      const SSessionSnapshot *sessionSnap = sessionEngine.GetSnapshot();

      stateEngine.ProcessState(*baseContext);
      const SMarketStateSnapshot *stateSnap = stateEngine.GetSnapshot();

      // 6. Update Volume state
      volumeEngine.ProcessVolume(*baseContext);
      const SVolumeSnapshot *volumeSnap = volumeEngine.GetSnapshot();

      // Rebuild context with updated Volume snapshot
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap);
      const SMarketContext *updatedContext = contextEngine.GetContext();

      bool success = (updatedContext != NULL && 
                      updatedContext.volume.sequenceNumber > 0 && 
                      updatedContext.volume.currentTickVolume == 100);

      CLogger::Info("Phase9DemoTest", StringFormat("Volume Context Verified: SeqNum=%d, TickVol=%d, RollingAvg=%.2f, RVol=%.2f, Trend=%d", 
                                                    updatedContext.volume.sequenceNumber, 
                                                    updatedContext.volume.currentTickVolume, 
                                                    updatedContext.volume.rollingAverageVolume,
                                                    updatedContext.volume.relativeVolume,
                                                    updatedContext.volume.volumeTrend));

      // 7. Cleanup
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

      PrintFormat("=== Phase 9 Volume Framework Demonstration Result: %s ===", success ? "PASSED" : "FAILED");
      return success;
   }
};
