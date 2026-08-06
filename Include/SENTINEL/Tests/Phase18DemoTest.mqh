//+------------------------------------------------------------------+
//|                                           Phase18DemoTest.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Apps/SentinelDeveloper/SentinelAppEngine.mqh"

/// @class CPhase18DemoTest
/// @brief Framework demonstration: Sentinel Developer Application lifecycle.
class CPhase18DemoTest
{
public:
   static void RunDemo()
   {
      Print("======================================================================");
      Print("   PROJECT SENTINEL - PHASE 18 DEVELOPER APPLICATION DEMONSTRATION");
      Print("======================================================================");

      // 1. Instantiate Application Engine
      CSentinelAppEngine appEngine;

      // 2. Demonstrate OnInit() 16-Subsystem Initialization Sequence
      Print("[1. ONINIT] Executing 16-Subsystem Sequential Initialization...");
      appEngine.InitializeSubsystems(0);

      // 3. Demonstrate OnCalculate() / OnTick() Cycle
      Print("----------------------------------------------------------------------");
      Print("[2. ONTICK] Processing incoming ticks through MarketContext pipeline...");
      for(int tick = 1; tick <= 5; tick++)
      {
         appEngine.ProcessTickCycle();
         SMarketContext ctx = appEngine.GetContext();
         Print(StringFormat("  - Tick #%d Processed -> Sequence #%d | High: %.2f | Close: %.2f",
                            tick, ctx.sequenceNumber, ctx.marketData.currentCandle.high, ctx.marketData.currentCandle.close));
      }

      // 4. Format & Display Developer Panel Content
      Print("----------------------------------------------------------------------");
      Print("[3. DEVELOPER PANEL] Formatting Telemetry Panel Output:");
      SMarketContext context = appEngine.GetContext();
      SSentinelAppPerformanceMetrics perf = appEngine.GetPerformanceMetrics();
      SVisualizationSnapshot visSnap = appEngine.GetVisualizationSnapshot();

      string panelContent = CSentinelAppMenu::FormatDeveloperPanel(context, perf, visSnap);
      Print(panelContent);

      // 5. Demonstrate OnDeinit() Shutdown
      Print("----------------------------------------------------------------------");
      Print("[4. ONDEINIT] Executing Graceful Framework Deinitialization...");
      appEngine.Shutdown();

      Print("======================================================================");
      Print("  SentinelDeveloper.mq5 is now the official developer application!");
      Print("  Strictly 100% Read-Only. Zero trade signals. Zero order execution.");
      Print("======================================================================");
   }
};
