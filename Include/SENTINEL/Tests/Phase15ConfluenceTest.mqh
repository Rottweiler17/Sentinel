//+------------------------------------------------------------------+
//|                                     Phase15ConfluenceTest.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Engines/Confluence/ConfluenceEngine.mqh"

/// @class CPhase15ConfluenceTest
/// @brief Test suite validating Confluence Engine aggregation, alignment, conflict, snapshot, and cache.
class CPhase15ConfluenceTest
{
public:
   static bool RunAllTests()
   {
      Print("=== Running Phase 15 Confluence Engine Unit Tests ===");
      bool pass = true;

      pass &= TestEvidenceAggregation();
      pass &= TestAlignmentCalculation();
      pass &= TestConflictDetection();
      pass &= TestSnapshotGeneration();
      pass &= TestCachingAndRepository();

      if(pass)
         Print("[SUCCESS] All Phase 15 Confluence Engine Unit Tests Passed!");
      else
         Print("[FAIL] One or more Phase 15 Unit Tests Failed!");

      return pass;
   }

private:
   static bool TestEvidenceAggregation()
   {
      SMarketContext context;
      context.Reset();
      context.timestamp = TimeCurrent();

      // Configure bullish structure & liquidity sweep
      context.structure.externalTrend = TREND_BULLISH;
      context.liquidity.sweepDirection = SWEEP_BULLISH;
      context.orderBlocks.activeBlocksCount = 2;
      context.orderBlocks.activeBlocks[0].direction = ORDERBLOCK_BULLISH;
      context.orderBlocks.activeBlocks[1].direction = ORDERBLOCK_BULLISH;
      context.fairValueGaps.activeGapsCount = 2;
      context.fairValueGaps.activeGaps[0].direction = FVG_BULLISH;
      context.fairValueGaps.activeGaps[1].direction = FVG_BULLISH;

      SConfluenceConfiguration config;
      config.SetDefaults();

      SEvidenceFactor evidence[EVIDENCE_SOURCE_COUNT];
      int activeCount = CEvidenceAggregator::AggregateEvidence(context, config, evidence);

      if(activeCount < 2)
      {
         Print("  [FAIL] TestEvidenceAggregation: Expected at least 2 active factors, got ", activeCount);
         return false;
      }

      if(evidence[(int)EVIDENCE_MARKET_STRUCTURE].bias != BIAS_BULLISH ||
         evidence[(int)EVIDENCE_LIQUIDITY].bias != BIAS_BULLISH)
      {
         Print("  [FAIL] TestEvidenceAggregation: Directional bias incorrect");
         return false;
      }

      Print("  [PASS] TestEvidenceAggregation Passed!");
      return true;
   }

   static bool TestAlignmentCalculation()
   {
      SEvidenceFactor evidence[EVIDENCE_SOURCE_COUNT];
      for(int i = 0; i < (int)EVIDENCE_SOURCE_COUNT; i++)
      {
         evidence[i].Reset();
         evidence[i].source = (ENUM_EVIDENCE_SOURCE)i;
         evidence[i].bias = BIAS_BULLISH;
         evidence[i].weight = 1.0;
         evidence[i].confidence = 1.0;
         evidence[i].score = 1.0;
      }

      int supporting = 0;
      double alignment = CAlignmentAnalyzer::CalculateAlignment(evidence, BIAS_BULLISH, supporting);

      if(alignment != 1.0 || supporting != (int)EVIDENCE_SOURCE_COUNT)
      {
         Print("  [FAIL] TestAlignmentCalculation: Expected perfect alignment 1.0, got ", alignment);
         return false;
      }

      Print("  [PASS] TestAlignmentCalculation Passed!");
      return true;
   }

   static bool TestConflictDetection()
   {
      SEvidenceFactor evidence[EVIDENCE_SOURCE_COUNT];
      SConfluenceConfiguration config;
      config.SetDefaults();

      for(int i = 0; i < (int)EVIDENCE_SOURCE_COUNT; i++)
      {
         evidence[i].Reset();
         evidence[i].source = (ENUM_EVIDENCE_SOURCE)i;
         evidence[i].weight = 1.0;
         evidence[i].confidence = 1.0;
         evidence[i].score = (i < 4) ? 1.0 : -1.0;
         evidence[i].bias  = (i < 4) ? BIAS_BULLISH : BIAS_BEARISH;
      }

      int conflicting = 0;
      double conflict = CConflictAnalyzer::CalculateConflict(evidence, BIAS_BULLISH, config, conflicting);

      if(conflict <= 0.0 || conflicting != 4)
      {
         Print("  [FAIL] TestConflictDetection: Expected conflict > 0.0 and conflicting=4, got conflict=", conflict);
         return false;
      }

      Print("  [PASS] TestConflictDetection Passed (Detected polarized conflict=", conflict, ")!");
      return true;
   }

   static bool TestSnapshotGeneration()
   {
      CConfluenceEngine engine;
      SMarketContext context;
      context.Reset();
      context.timestamp = TimeCurrent();

      context.structure.externalTrend = TREND_BULLISH;
      context.liquidity.sweepDirection = SWEEP_BULLISH;

      SConfluenceSnapshot snapshot;
      bool success = engine.Evaluate(context, snapshot);

      if(!success || snapshot.snapshotId == 0 || snapshot.overallConfluenceScore <= 0.0)
      {
         Print("  [FAIL] TestSnapshotGeneration: Failed to generate valid ConfluenceSnapshot");
         return false;
      }

      Print("  [PASS] TestSnapshotGeneration Passed (Score=", snapshot.overallConfluenceScore, ", Align=", snapshot.alignmentScore, ")!");
      return true;
   }

   static bool TestCachingAndRepository()
   {
      CConfluenceEngine engine;
      SMarketContext context;
      context.Reset();
      context.timestamp = TimeCurrent();

      SConfluenceSnapshot snap1, snap2;
      engine.Evaluate(context, snap1);
      engine.Evaluate(context, snap2);

      SConfluenceSnapshot latest;
      if(!engine.GetSnapshot(latest) || latest.snapshotId != snap2.snapshotId)
      {
         Print("  [FAIL] TestCachingAndRepository: Latest snapshot mismatch");
         return false;
      }

      Print("  [PASS] TestCachingAndRepository Passed!");
      return true;
   }
};
