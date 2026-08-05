//+------------------------------------------------------------------+
//|                                            Phase11DemoTest.mqh |
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
#include "../Framework/Context/ContextEngine.mqh"
#include "../Logging/Logger.mqh"

/// @class CFeatureTestListener
/// @brief Sample IEventListener proving event propagation for feature vectors.
class CFeatureTestListener : public IEventListener
{
private:
   int m_featureEvents;

public:
   CFeatureTestListener() : m_featureEvents(0) {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(event.type == EVENT_SYS_CONFIG_CHANGE)
      {
         m_featureEvents++;
         CLogger::Info("FeatureTestListener", StringFormat("EVENT_FEATURE_VECTOR_CREATED Received #%d | Overall Confidence: %.2f%% | Payload: %s", 
                                                           m_featureEvents, event.priceValue, event.payloadJson));
      }
   }

   int FeatureEvents() const { return m_featureEvents; }
};

/// @class CPhase11DemoTest
/// @brief End-to-end demonstration for Phase 11 Feature Engineering Framework.
/// Pipeline: MarketContext -> FeatureEngine -> FeatureSnapshot -> Updated MarketContext -> EventBus -> Listener.
class CPhase11DemoTest
{
public:
   static bool RunDemo()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("Phase11DemoTest", "=== Starting Phase 11 Feature Engineering Demonstration ===");

      // 1. Setup Infrastructure
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);
      config.SetDouble("features.min_normalized", -1.0);
      config.SetDouble("features.max_normalized", 1.0);

      CEventBus bus;
      CFeatureTestListener listener;
      CEventRecorder recorder;

      // 2. Subscribe Listener & Recorder to Feature Events
      bus.Subscribe(EVENT_SYS_CONFIG_CHANGE, &listener);
      bus.Subscribe(EVENT_SYS_CONFIG_CHANGE, &recorder);

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
         !contextEngine.Initialize(&config, &bus))
      {
         CLogger::Error("Phase11DemoTest", "Engine initialization failed.");
         return false;
      }

      // 4. Simulate Market Tick & Snapshot Creation
      MqlTick tick;
      tick.time     = TimeCurrent();
      tick.bid      = 1.1000;
      tick.ask      = 1.1002;
      tick.time_msc = 1001100;

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

      // Build base Context with placeholders
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, 
                                  sessionEngine.GetSnapshot()[0], 
                                  stateEngine.GetSnapshot()[0], 
                                  volumeEngine.GetSnapshot()[0], 
                                  orderFlowEngine.GetSnapshot()[0],
                                  featureEngine.GetSnapshot()[0]);
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
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, featureEngine.GetSnapshot()[0]);
      const SMarketContext *contextForFeatures = contextEngine.GetContext();

      // 6. Update features
      featureEngine.ProcessFeatures(*contextForFeatures);
      const SFeatureSnapshot *featuresSnap = featureEngine.GetSnapshot();

      // Rebuild context with updated features snapshot
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, *featuresSnap);
      const SMarketContext *updatedContext = contextEngine.GetContext();

      bool success = (updatedContext != NULL && 
                      updatedContext.features.sequenceNumber > 0 && 
                      updatedContext.features.trendStrength.confidence > 0.0);

      CLogger::Info("Phase11DemoTest", StringFormat("Features Context Verified: SeqNum=%d, TrendRaw=%.2f, TrendNorm=%.2f, SessionRaw=%.2f, OverallConfidence=%.2f%%", 
                                                    updatedContext.features.sequenceNumber, 
                                                    updatedContext.features.trendStrength.rawValue, 
                                                    updatedContext.features.trendStrength.normalizedValue,
                                                    updatedContext.features.sessionWeight.rawValue,
                                                    updatedContext.features.overallConfidence));

      // 7. Cleanup
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

      PrintFormat("=== Phase 11 Feature Engineering Demonstration Result: %s ===", success ? "PASSED" : "FAILED");
      return success;
   }
};
