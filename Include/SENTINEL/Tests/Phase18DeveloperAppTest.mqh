//+------------------------------------------------------------------+
//|                                  Phase18DeveloperAppTest.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Apps/SentinelDeveloper/SentinelAppEngine.mqh"

/// @class CPhase18DeveloperAppTest
/// @brief Integration test suite validating Sentinel Developer Application initialization, tick processing, and shutdown.
class CPhase18DeveloperAppTest
{
public:
   static bool RunAllTests()
   {
      Print("=== Running Phase 18 Sentinel Developer Application Integration Tests ===");
      bool pass = true;

      pass &= TestSubsystemInitialization();
      pass &= TestTickCycleExecution();
      pass &= TestPerformanceTracker();
      pass &= TestReplayController();
      pass &= TestShutdownCleanup();

      if(pass)
         Print("[SUCCESS] All Phase 18 Developer Application Unit Tests Passed!");
      else
         Print("[FAIL] One or more Phase 18 Unit Tests Failed!");

      return pass;
   }

private:
   static bool TestSubsystemInitialization()
   {
      CSentinelAppEngine appEngine;
      bool success = appEngine.InitializeSubsystems(0);

      if(!success)
      {
         Print("  [FAIL] TestSubsystemInitialization: 16-Subsystem initialization failed");
         return false;
      }

      Print("  [PASS] TestSubsystemInitialization Passed (16 Subsystems Initialized)!");
      return true;
   }

   static bool TestTickCycleExecution()
   {
      CSentinelAppEngine appEngine;
      appEngine.InitializeSubsystems(0);

      bool success = appEngine.ProcessTickCycle();
      SMarketContext context = appEngine.GetContext();

      if(!success || context.sequenceNumber == 0)
      {
         Print("  [FAIL] TestTickCycleExecution: ProcessTickCycle failed");
         return false;
      }

      Print("  [PASS] TestTickCycleExecution Passed (Sequence #", context.sequenceNumber, ")!");
      return true;
   }

   static bool TestPerformanceTracker()
   {
      CSentinelAppPerformanceTracker tracker;
      tracker.RecordTickCompletion(0.15, 12);
      SSentinelAppPerformanceMetrics metrics = tracker.GetMetrics();

      if(metrics.tickProcessingMs != 0.15 || metrics.chartObjectsCount != 12)
      {
         Print("  [FAIL] TestPerformanceTracker: Metric value mismatch");
         return false;
      }

      Print("  [PASS] TestPerformanceTracker Passed!");
      return true;
   }

   static bool TestReplayController()
   {
      CSentinelAppReplayController replay;
      replay.Initialize();
      replay.SetSpeedMultiplier(10);

      if(replay.GetSpeedMultiplier() != 10)
      {
         Print("  [FAIL] TestReplayController: Replay speed multiplier mismatch");
         return false;
      }

      Print("  [PASS] TestReplayController Passed!");
      return true;
   }

   static bool TestShutdownCleanup()
   {
      CSentinelAppEngine appEngine;
      appEngine.InitializeSubsystems(0);
      appEngine.ProcessTickCycle();
      appEngine.Shutdown();

      SMarketContext context = appEngine.GetContext();
      if(context.sequenceNumber != 0)
      {
         Print("  [FAIL] TestShutdownCleanup: Context not reset after shutdown");
         return false;
      }

      Print("  [PASS] TestShutdownCleanup Passed!");
      return true;
   }
};
