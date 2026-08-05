//+------------------------------------------------------------------+
//|                                            Phase12DemoTest.mqh |
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
#include "../Framework/Context/ContextEngine.mqh"
#include "../Logging/Logger.mqh"

/// @class CDecisionTestListener
/// @brief Sample IEventListener proving event propagation for generic decision updates.
class CDecisionTestListener : public IEventListener
{
private:
   int m_decisionEvents;

public:
   CDecisionTestListener() : m_decisionEvents(0) {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(event.type == EVENT_TRD_DECISION_READY)
      {
         m_decisionEvents++;
         CLogger::Info("DecisionTestListener", StringFormat("EVENT_DECISION_UPDATED Received #%d | Overall Score: %.2f%% | Recommendation Code: %d | Payload: %s", 
                                                             m_decisionEvents, event.priceValue, event.entityId, event.payloadJson));
      }
   }

   int DecisionEvents() const { return m_decisionEvents; }
};

/// @class CPhase12DemoTest
/// @brief End-to-end demonstration for Phase 12 Decision Framework.
/// Pipeline: FeatureSnapshot -> DecisionEngine -> DecisionSnapshot -> EventBus -> Listener -> CLogger.
class CPhase12DemoTest
{
public:
   static bool RunDemo()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("Phase12DemoTest", "=== Starting Phase 12 Decision Framework Demonstration ===");

      // 1. Setup Infrastructure
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);
      config.SetDouble("decisions.confluence_threshold", 55.0);
      config.SetDouble("decisions.score_threshold", 50.0);

      CEventBus bus;
      CDecisionTestListener listener;
      CEventRecorder recorder;

      // 2. Subscribe Listener & Recorder to Decision Events
      bus.Subscribe(EVENT_TRD_DECISION_READY, &listener);
      bus.Subscribe(EVENT_TRD_DECISION_READY, &recorder);

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
         !contextEngine.Initialize(&config, &bus))
      {
         CLogger::Error("Phase12DemoTest", "Engine initialization failed.");
         return false;
      }

      // 4. Simulate Market Tick & Snapshot Creation
      MqlTick tick;
      tick.time     = TimeCurrent();
      tick.bid      = 1.1000;
      tick.ask      = 1.1002;
      tick.time_msc = 1001200;

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
                                  featureEngine.GetSnapshot()[0],
                                  decisionEngine.GetSnapshot()[0]);
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

      // Rebuild context for feature calculations
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, featureEngine.GetSnapshot()[0], decisionEngine.GetSnapshot()[0]);
      const SMarketContext *contextForFeatures = contextEngine.GetContext();

      // Update features
      featureEngine.ProcessFeatures(*contextForFeatures);
      const SFeatureSnapshot *featuresSnap = featureEngine.GetSnapshot();

      // Rebuild context for decision calculations
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, *featuresSnap, decisionEngine.GetSnapshot()[0]);
      const SMarketContext *contextForDecisions = contextEngine.GetContext();

      // 6. Update Decisions
      decisionEngine.ProcessDecision(*featuresSnap);
      const SDecisionSnapshot *decisionsSnap = decisionEngine.GetSnapshot();

      // Rebuild context with updated decisions snapshot
      contextEngine.UpdateContext(*marketSnap, *structSnap, *liqSnap, *zoneSnap, *sessionSnap, *stateSnap, *volumeSnap, *orderFlowSnap, *featuresSnap, *decisionsSnap);
      const SMarketContext *updatedContext = contextEngine.GetContext();

      bool success = (updatedContext != NULL && 
                      updatedContext.decisions.sequenceNumber > 0 && 
                      updatedContext.decisions.overallScore > 0.0);

      CLogger::Info("Phase12DemoTest", StringFormat("Decisions Context Verified: SeqNum=%d, OverallScore=%.2f%%, ConfluenceScore=%.2f%%, RecCode=%d, Confidence=%.2f%%", 
                                                    updatedContext.decisions.sequenceNumber, 
                                                    updatedContext.decisions.overallScore, 
                                                    updatedContext.decisions.confluenceScore,
                                                    (int)updatedContext.decisions.recommendation,
                                                    updatedContext.decisions.confidence));

      // 7. Cleanup
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

      PrintFormat("=== Phase 12 Decision Framework Demonstration Result: %s ===", success ? "PASSED" : "FAILED");
      return success;
   }
};
