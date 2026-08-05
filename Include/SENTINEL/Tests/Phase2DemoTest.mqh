//+------------------------------------------------------------------+
//|                                             Phase2DemoTest.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Common/Interfaces.mqh"
#include "../Events/EventBus.mqh"
#include "../Data/DataEngine.mqh"
#include "../Logging/Logger.mqh"
#include "../Config/ConfigEngine.mqh"

/// @class CTestListener
/// @brief Sample IEventListener subscriber proving event propagation from EventBus to listening engines.
class CTestListener : public IEventListener
{
private:
   int m_receivedTicks;
   int m_receivedBars;

public:
   CTestListener() : m_receivedTicks(0), m_receivedBars(0) {}

   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(event.type == EVENT_MKT_TICK)
      {
         m_receivedTicks++;
         CLogger::Info("TestListener", StringFormat("EVENT_MKT_TICK Received #%d | Symbol: %s | Price: %.5f", 
                                                    m_receivedTicks, event.symbol, event.priceValue));
      }
      else if(event.type == EVENT_MKT_NEW_BAR)
      {
         m_receivedBars++;
         CLogger::Info("TestListener", StringFormat("EVENT_MKT_NEW_BAR Received #%d | Timeframe: %d", 
                                                    m_receivedBars, event.timeframe));
      }
   }

   int ReceivedTicks() const { return m_receivedTicks; }
   int ReceivedBars()  const { return m_receivedBars; }
};

/// @class CPhase2DemoTest
/// @brief End-to-end architecture demonstration for Phase 2.
/// Flow: MT5 Tick -> TickEngine -> DataEngine -> MarketDataSnapshot -> EventBus -> CTestListener -> CLogger.
class CPhase2DemoTest
{
public:
   static bool RunDemo()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("Phase2DemoTest", "=== Starting Phase 2 Architectural Demonstration ===");

      // 1. Instantiate Core Infrastructure
      CConfigEngine config;
      config.SetString("symbol", _Symbol);
      config.SetInt("timeframe", _Period);

      CEventBus bus;
      CTestListener listener;

      // 2. Subscribe Listener to Market Events
      bus.Subscribe(EVENT_MKT_TICK, &listener);
      bus.Subscribe(EVENT_MKT_NEW_BAR, &listener);

      // 3. Initialize DataEngine
      CDataEngine dataEngine;
      if(!dataEngine.Initialize(&config, &bus))
      {
         CLogger::Error("Phase2DemoTest", "DataEngine initialization failed.");
         return false;
      }

      // 4. Simulate Incoming MT5 Tick
      MqlTick simTick;
      simTick.time     = TimeCurrent();
      simTick.bid      = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      simTick.ask      = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      simTick.last     = simTick.bid;
      simTick.volume   = 1;
      simTick.time_msc = 10002000;
      simTick.flags    = TICK_FLAG_BID | TICK_FLAG_ASK;

      if(simTick.bid <= 0.0) simTick.bid = 1.1000;
      if(simTick.ask <= 0.0) simTick.ask = 1.1005;

      // Execute Tick Pipeline: TickEngine -> DataEngine -> Snapshot -> EventBus -> Listener
      dataEngine.OnTick(simTick);

      // 5. Verify Immutable MarketDataSnapshot
      const SMarketDataSnapshot *snapshot = dataEngine.GetSnapshot();
      bool snapshotValid = (snapshot != NULL && snapshot.bid == simTick.bid && snapshot.symbol == _Symbol);

      CLogger::Info("Phase2DemoTest", StringFormat("Snapshot Verified: Symbol=%s, Bid=%.5f, Spread=%d pts", 
                                                 snapshot.symbol, snapshot.bid, snapshot.spread));

      // 6. Shutdown
      dataEngine.Shutdown();
      CLogger::Flush();
      CLogger::Shutdown();

      bool success = (listener.ReceivedTicks() > 0 && snapshotValid);
      PrintFormat("=== Phase 2 Architectural Demonstration Result: %s ===", success ? "PASSED" : "FAILED");
      return success;
   }
};
