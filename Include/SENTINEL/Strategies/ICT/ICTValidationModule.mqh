//+------------------------------------------------------------------+
//|                                         ICTValidationModule.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "ICTChecklist.mqh"
#include "ICTScenarioAnalyzer.mqh"
#include "ICTValidationRepository.mqh"
#include "ICTValidationStatistics.mqh"
#include "ICTValidationEvents.mqh"

/// @class CICTValidationModule
/// @brief Primary facade class validating whether MarketContext satisfies ICT Strategy criteria.
class CICTValidationModule
{
private:
   CICTValidationRepository m_repository;
   SICTValidationStatistics m_stats;
   SICTValidationSnapshot   m_currentSnapshot;
   ulong                    m_sequenceNumber;

public:
   CICTValidationModule() : m_sequenceNumber(0)
   {
      m_currentSnapshot.Reset();
      m_stats.Reset();
   }

   ~CICTValidationModule() {}

   /// @brief Evaluates current MarketContext against ICT Strategy criteria.
   bool ValidateContext(const SMarketContext &context, SICTValidationSnapshot &outSnapshot)
   {
      outSnapshot.Reset();
      outSnapshot.timestamp      = context.timestamp;
      outSnapshot.snapshotId     = ++m_sequenceNumber;
      outSnapshot.sequenceNumber = m_sequenceNumber;

      // 1. Evaluate 8 individual conditions
      SICTConditionResult rawConditions[ICT_CONDITION_COUNT];
      CICTChecklist::EvaluateChecklist(context, rawConditions);

      // 2. Synthesize metrics
      CICTScenarioAnalyzer::AnalyzeScenario(rawConditions, outSnapshot);

      // 3. Store in repository
      m_repository.Store(outSnapshot);

      // 4. Update statistics
      m_stats.RecordEvaluation(outSnapshot.overallValidationScore, outSnapshot.isSetupValid);

      m_currentSnapshot = outSnapshot;
      return true;
   }

   /// @brief Retrieves latest validation snapshot.
   bool GetLatestSnapshot(SICTValidationSnapshot &outSnapshot) const
   {
      if(m_currentSnapshot.snapshotId == 0)
         return false;
      outSnapshot = m_currentSnapshot;
      return true;
   }

   /// @brief Generates text report summarizing satisfied vs missing ICT conditions.
   static string FormatValidationReport(const SICTValidationSnapshot &snapshot)
   {
      string report = "=== ICT STRATEGY VALIDATION REPORT ===\n";
      report += StringFormat("Validation Score: %.1f%% (Confidence: %.1f%%)\n", 
                             snapshot.overallValidationScore * 100.0,
                             snapshot.confidence * 100.0);
      report += StringFormat("Setup Status:     %s (Satisfied: %d / %d)\n", 
                             (snapshot.isSetupValid ? "[VALID SETUP]" : "[INCOMPLETE SETUP]"),
                             snapshot.satisfiedCount, (int)ICT_CONDITION_COUNT);
      report += "--------------------------------------\n";
      report += "SATISFIED CONDITIONS:\n";

      int countSat = 0;
      for(int i = 0; i < (int)ICT_CONDITION_COUNT; i++)
      {
         if(snapshot.conditions[i].satisfied)
         {
            countSat++;
            report += StringFormat("  [OK] %s\n", snapshot.conditions[i].description);
         }
      }
      if(countSat == 0) report += "  (None)\n";

      report += "--------------------------------------\n";
      report += "MISSING / UNSATISFIED CONDITIONS:\n";
      int countMiss = 0;
      for(int i = 0; i < (int)ICT_CONDITION_COUNT; i++)
      {
         if(!snapshot.conditions[i].satisfied)
         {
            countMiss++;
            report += StringFormat("  [X]  %s\n", snapshot.conditions[i].description);
         }
      }
      if(countMiss == 0) report += "  (None - Perfect ICT Setup)\n";

      return report;
   }

   /// @brief Returns statistics telemetry.
   SICTValidationStatistics GetStatistics() const { return m_stats; }
};
