//+------------------------------------------------------------------+
//|                                  Phase17ICTValidationTest.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Strategies/ICT/ICTValidationModule.mqh"

/// @class CPhase17ICTValidationTest
/// @brief Unit test suite validating ICT Strategy Validation Pack checklist, scoring, repository, and reporting.
class CPhase17ICTValidationTest
{
public:
   static bool RunAllTests()
   {
      Print("=== Running Phase 17 ICT Strategy Validation Pack Unit Tests ===");
      bool pass = true;

      pass &= TestChecklistEvaluation();
      pass &= TestScenarioAggregation();
      pass &= TestRepositoryStorage();
      pass &= TestReportFormatting();

      if(pass)
         Print("[SUCCESS] All Phase 17 ICT Validation Pack Unit Tests Passed!");
      else
         Print("[FAIL] One or more Phase 17 Unit Tests Failed!");

      return pass;
   }

private:
   static bool TestChecklistEvaluation()
   {
      SMarketContext context;
      context.Reset();
      context.timestamp = TimeCurrent();

      // Configure valid ICT setup context
      context.structure.externalTrend = TREND_BULLISH;
      context.liquidity.sweepDirection = SWEEP_BULLISH;
      context.orderBlocks.activeBlocksCount = 2;
      context.fairValueGaps.activeGapsCount = 1;
      context.session.currentSession = SESSION_LONDON;
      context.state.currentState = STATE_ENV_TRENDING_BULLISH;
      context.confluence.overallConfluenceScore = 0.75;
      context.confluence.alignmentScore = 0.80;
      context.decisions.overallScore = 0.70;
      context.decisions.confidence = 0.80;

      SICTConditionResult rawConds[ICT_CONDITION_COUNT];
      CICTChecklist::EvaluateChecklist(context, rawConds);

      int satisfied = 0;
      for(int i = 0; i < (int)ICT_CONDITION_COUNT; i++)
      {
         if(rawConds[i].satisfied)
            satisfied++;
      }

      if(satisfied != 8)
      {
         Print("  [FAIL] TestChecklistEvaluation: Expected all 8 conditions satisfied, got ", satisfied);
         return false;
      }

      Print("  [PASS] TestChecklistEvaluation Passed (All 8 ICT conditions satisfied)!");
      return true;
   }

   static bool TestScenarioAggregation()
   {
      CICTValidationModule module;
      SMarketContext context;
      context.Reset();
      context.timestamp = TimeCurrent();

      context.structure.externalTrend = TREND_BULLISH;
      context.liquidity.sweepDirection = SWEEP_BULLISH;
      context.orderBlocks.activeBlocksCount = 1;
      context.fairValueGaps.activeGapsCount = 1;
      context.session.currentSession = SESSION_LONDON;
      context.state.currentState = STATE_ENV_TRENDING_BULLISH;
      context.confluence.overallConfluenceScore = 0.80;
      context.confluence.alignmentScore = 0.85;
      context.decisions.overallScore = 0.75;
      context.decisions.confidence = 0.80;

      SICTValidationSnapshot snap;
      module.ValidateContext(context, snap);

      if(!snap.isSetupValid || snap.overallValidationScore < 0.60)
      {
         Print("  [FAIL] TestScenarioAggregation: Valid setup failed to pass validation threshold");
         return false;
      }

      Print("  [PASS] TestScenarioAggregation Passed (Score=", snap.overallValidationScore, ")!");
      return true;
   }

   static bool TestRepositoryStorage()
   {
      CICTValidationModule module;
      SMarketContext context;
      context.Reset();
      context.timestamp = TimeCurrent();

      SICTValidationSnapshot snap;
      module.ValidateContext(context, snap);

      SICTValidationSnapshot latest;
      if(!module.GetLatestSnapshot(latest) || latest.snapshotId != snap.snapshotId)
      {
         Print("  [FAIL] TestRepositoryStorage: Repository snapshot mismatch");
         return false;
      }

      Print("  [PASS] TestRepositoryStorage Passed!");
      return true;
   }

   static bool TestReportFormatting()
   {
      SICTValidationSnapshot snap;
      snap.Reset();
      snap.overallValidationScore = 0.85;
      snap.satisfiedCount = 7;
      snap.missingCount = 1;
      snap.isSetupValid = true;

      string report = CICTValidationModule::FormatValidationReport(snap);
      if(StringFind(report, "ICT STRATEGY VALIDATION REPORT") < 0 ||
         StringFind(report, "VALID SETUP") < 0)
      {
         Print("  [FAIL] TestReportFormatting: Format string missing header");
         return false;
      }

      Print("  [PASS] TestReportFormatting Passed!");
      return true;
   }
};
