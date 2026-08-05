//+------------------------------------------------------------------+
//|                                             Phase3DemoTest.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Common/Interfaces.mqh"
#include "../Events/EventBus.mqh"
#include "../Events/EventRecorder.mqh"
#include "../Data/DataEngine.mqh"
#include "../Data/SnapshotHistory.mqh"
#include "../Engines/Structure/StructureEngine.mqh"
#include "../Logging/Logger.mqh"

/// @class CStructureTestListener
/// @brief Sample IEventListener proving event propagation for swings, BOS, and CHOCH from StructureEngine.
class CStructureTestListener : public IEventListener
{
private:
   int m_swingEvents;
   int m_bosEvents;
   int m_chochEvents;

public:
   CStructureTestListener() : m_swingEvents(0), m_bosEvents(0), m_chochEvents(0) {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(event.type == EVENT_MKT_SWING_FOUND)
      {
         m_swingEvents++;
         CLogger::Info("StructureTestListener", StringFormat("EVENT_MKT_SWING_FOUND Received #%d | Price: %.5f", 
                                                             m_swingEvents, event.priceValue));
      }
      else if(event.type == EVENT_MKT_BOS)
      {
         m_bosEvents++;
         CLogger::Info("StructureTestListener", StringFormat("EVENT_MKT_BOS Received #%d | BreakPrice: %.5f | Payload: %s", 
                                                             m_bosEvents, event.priceValue, event.payloadJson));
      }
      else if(event.type == EVENT_MKT_CHOCH)
      {
         m_chochEvents++;
         CLogger::Info("StructureTestListener", StringFormat("EVENT_MKT_CHOCH Received #%d | BreakPrice: %.5f | Payload: %s", 
                                                             m_chochEvents, event.priceValue, event.payloadJson));
      }
   }

   int SwingEvents() const { return m_swingEvents; }
   int BOSEvents()   const { return m_bosEvents; }
   int CHOCHEvents() const { return m_chochEvents; }
};

/// @class CPhase3DemoTest
/// @brief End-to-end demonstration for Phase 3 Market Structure Engine including State Machine, Event Replay, and Snapshot History.
class CPhase3DemoTest
{
public:
   static bool RunDemo()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("Phase3DemoTest", "=== Starting Phase 3 Market Structure Engine Demonstration ===");

      // 1. Setup Infrastructure
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);
      config.SetInt("structure.swing_length", 3);

      CEventBus bus;
      CStructureTestListener listener;
      CEventRecorder recorder;
      CSnapshotHistory history;

      // 2. Subscribe Listener & Event Recorder
      bus.Subscribe(EVENT_MKT_SWING_FOUND, &listener);
      bus.Subscribe(EVENT_MKT_BOS, &listener);
      bus.Subscribe(EVENT_MKT_CHOCH, &listener);
      bus.Subscribe(EVENT_MKT_SWING_FOUND, &recorder);
      bus.Subscribe(EVENT_MKT_BOS, &recorder);
      bus.Subscribe(EVENT_MKT_CHOCH, &recorder);

      // 3. Initialize Engines
      CDataEngine dataEngine;
      CStructureEngine structureEngine;

      if(!dataEngine.Initialize(&config, &bus) || !structureEngine.Initialize(&config, &bus))
      {
         CLogger::Error("Phase3DemoTest", "Engine initialization failed.");
         return false;
      }

      // 4. Simulate Price Tick -> MarketDataSnapshot
      MqlTick tick;
      tick.time     = TimeCurrent();
      tick.bid      = 1.1000;
      tick.ask      = 1.1002;
      tick.time_msc = 1000;

      dataEngine.OnTick(tick);
      const SMarketDataSnapshot *marketSnap = dataEngine.GetSnapshot();
      history.AddMarketSnapshot(*marketSnap);

      // 5. Register Swings & Process Structure with State Machine
      SSwingPoint swingLow1;  swingLow1.id = 1; swingLow1.price = 1.0950; swingLow1.type = SWING_TYPE_LOW;  swingLow1.time = tick.time - 300; swingLow1.timeframe = PERIOD_M5;
      SSwingPoint swingHigh1; swingHigh1.id = 2; swingHigh1.price = 1.1100; swingHigh1.type = SWING_TYPE_HIGH; swingHigh1.time = tick.time - 200; swingHigh1.timeframe = PERIOD_M5;

      structureEngine.RegisterSwing(swingLow1);
      structureEngine.RegisterSwing(swingHigh1);
      structureEngine.ProcessStructure(*marketSnap);

      const SStructureSnapshot *structSnap = structureEngine.GetSnapshot();
      history.AddStructureSnapshot(*structSnap);

      bool snapshotValid = (structSnap != NULL && structSnap.latestSwingHigh.price == 1.1100 && structSnap.sequenceNumber > 0);

      CLogger::Info("Phase3DemoTest", StringFormat("Snapshot Versioning Verified: SeqNum=%d, State=%d, RecordedEvents=%d", 
                                                    structSnap.sequenceNumber, structSnap.currentState, recorder.RecordedEventsCount()));

      // 6. Test Event Replay
      recorder.ReplayEvents(&listener);

      // 7. Cleanup
      structureEngine.Shutdown();
      dataEngine.Shutdown();
      CLogger::Flush();
      CLogger::Shutdown();

      bool success = (listener.SwingEvents() >= 2 && snapshotValid && history.StructureSnapshotCount() > 0);
      PrintFormat("=== Phase 3 Market Structure Demonstration Result: %s ===", success ? "PASSED" : "FAILED");
      return success;
   }
};
