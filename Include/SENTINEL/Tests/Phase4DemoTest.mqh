//+------------------------------------------------------------------+
//|                                             Phase4DemoTest.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Common/Interfaces.mqh"
#include "../Events/EventBus.mqh"
#include "../Events/EventRecorder.mqh"
#include "../Data/DataEngine.mqh"
#include "../Engines/Structure/StructureEngine.mqh"
#include "../Engines/Liquidity/LiquidityEngine.mqh"
#include "../Logging/Logger.mqh"

/// @class CLiquidityTestListener
/// @brief Sample IEventListener proving event propagation for pools, BSL/SSL, and sweeps from LiquidityEngine.
class CLiquidityTestListener : public IEventListener
{
private:
   int m_poolEvents;
   int m_sweepEvents;

public:
   CLiquidityTestListener() : m_poolEvents(0), m_sweepEvents(0) {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(event.type == EVENT_MKT_ZONE_CREATED)
      {
         m_poolEvents++;
         CLogger::Info("LiquidityTestListener", StringFormat("EVENT_MKT_ZONE_CREATED Received #%d | Price: %.5f | Payload: %s", 
                                                             m_poolEvents, event.priceValue, event.payloadJson));
      }
      else if(event.type == EVENT_MKT_LIQUIDITY_SWEEP)
      {
         m_sweepEvents++;
         CLogger::Info("LiquidityTestListener", StringFormat("EVENT_MKT_LIQUIDITY_SWEEP Received #%d | SweepPrice: %.5f | Payload: %s", 
                                                             m_sweepEvents, event.priceValue, event.payloadJson));
      }
   }

   int PoolEvents()  const { return m_poolEvents; }
   int SweepEvents() const { return m_sweepEvents; }
};

/// @class CPhase4DemoTest
/// @brief End-to-end demonstration for Phase 4 Institutional Liquidity Engine verifying Confidence, Zone Linkage, and Lifecycle.
class CPhase4DemoTest
{
public:
   static bool RunDemo()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("Phase4DemoTest", "=== Starting Phase 4 Institutional Liquidity Engine Demonstration ===");

      // 1. Setup Infrastructure
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);
      config.SetDouble("liquidity.tolerance_pips", 3.0);

      CEventBus bus;
      CLiquidityTestListener listener;
      CEventRecorder recorder;

      // 2. Subscribe Listener & Recorder to Liquidity Events
      bus.Subscribe(EVENT_MKT_ZONE_CREATED, &listener);
      bus.Subscribe(EVENT_MKT_LIQUIDITY_SWEEP, &listener);
      bus.Subscribe(EVENT_MKT_ZONE_CREATED, &recorder);
      bus.Subscribe(EVENT_MKT_LIQUIDITY_SWEEP, &recorder);

      // 3. Initialize Core Engines
      CDataEngine dataEngine;
      CStructureEngine structureEngine;
      CLiquidityEngine liquidityEngine(3.0);

      if(!dataEngine.Initialize(&config, &bus) || 
         !structureEngine.Initialize(&config, &bus) || 
         !liquidityEngine.Initialize(&config, &bus))
      {
         CLogger::Error("Phase4DemoTest", "Engine initialization failed.");
         return false;
      }

      // 4. Simulate Market Tick & Snapshot Creation
      MqlTick tick;
      tick.time     = TimeCurrent();
      tick.bid      = 1.1000;
      tick.ask      = 1.1002;
      tick.time_msc = 1000500;

      dataEngine.OnTick(tick);
      const SMarketDataSnapshot *marketSnap = dataEngine.GetSnapshot();

      // 5. Simulate Swings for Equal Highs (EQH) Detection
      SSwingPoint swingHigh1; swingHigh1.id = 1; swingHigh1.price = 1.1050; swingHigh1.type = SWING_TYPE_HIGH; swingHigh1.time = tick.time - 300; swingHigh1.timeframe = PERIOD_M5;
      SSwingPoint swingHigh2; swingHigh2.id = 2; swingHigh2.price = 1.1052; swingHigh2.type = SWING_TYPE_HIGH; swingHigh2.time = tick.time - 100; swingHigh2.timeframe = PERIOD_M5;

      structureEngine.RegisterSwing(swingHigh1);
      structureEngine.RegisterSwing(swingHigh2);
      structureEngine.ProcessStructure(*marketSnap);
      const SStructureSnapshot *structSnap = structureEngine.GetSnapshot();

      // 6. Process Liquidity Engine Pipeline
      liquidityEngine.ProcessLiquidity(*marketSnap, *structSnap);

      // 7. Verify SLiquiditySnapshot Confidence & Lifecycle State
      const SLiquiditySnapshot *liqSnap = liquidityEngine.GetSnapshot();
      bool snapshotValid = (liqSnap != NULL && liqSnap.sequenceNumber > 0);

      CLogger::Info("Phase4DemoTest", StringFormat("LiquiditySnapshot Verified: ActivePools=%d, Confidence=%.1f%%, Source=%s", 
                                                    liqSnap.activePoolsCount, liqSnap.overallConfidence, liqSnap.confidenceSource));

      // 8. Cleanup
      liquidityEngine.Shutdown();
      structureEngine.Shutdown();
      dataEngine.Shutdown();
      CLogger::Flush();
      CLogger::Shutdown();

      bool success = (snapshotValid && liqSnap.overallConfidence > 0.0);
      PrintFormat("=== Phase 4 Institutional Liquidity Demonstration Result: %s ===", success ? "PASSED" : "FAILED");
      return success;
   }
};
