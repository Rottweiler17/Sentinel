//+------------------------------------------------------------------+
//|                                             ConfluenceEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "IConfluenceEngine.mqh"
#include "ConfluenceAnalyzer.mqh"
#include "ConfluenceRepository.mqh"
#include "ConfluenceStatistics.mqh"
#include "ConfluenceValidator.mqh"
#include "ConfluenceEvents.mqh"

/// @class CConfluenceEngine
/// @brief Primary Confluence Engine evaluating agreement/conflict across 8 analytical modules.
class CConfluenceEngine : public IConfluenceEngine
{
private:
   CConfluenceAnalyzer   m_analyzer;
   CConfluenceRepository m_repository;
   SConfluenceStatistics m_stats;
   SConfluenceSnapshot   m_currentSnapshot;

   ulong                 m_nextSnapshotId;
   ulong                 m_sequenceNumber;

public:
   CConfluenceEngine() : m_nextSnapshotId(1), m_sequenceNumber(0)
   {
      m_currentSnapshot.Reset();
      m_stats.Reset();
   }

   virtual ~CConfluenceEngine() {}

   /// @brief Evaluates current MarketContext and generates SConfluenceSnapshot.
   virtual bool Evaluate(const SMarketContext &context, SConfluenceSnapshot &outSnapshot) override
   {
      if(!CConfluenceValidator::ValidateContext(context))
         return false;

      SConfluenceSnapshot snapshot;
      if(!m_analyzer.Analyze(context, snapshot))
         return false;

      // Assign lineage metadata
      snapshot.snapshotId     = m_nextSnapshotId++;
      snapshot.parentId       = m_currentSnapshot.snapshotId;
      snapshot.sequenceNumber = ++m_sequenceNumber;

      // Validate snapshot bounds
      if(!CConfluenceValidator::ValidateSnapshot(snapshot))
         return false;

      // Store in repository
      m_repository.Store(snapshot);

      // Record statistics
      m_stats.RecordEvaluation(snapshot.overallConfluenceScore, snapshot.alignmentScore, snapshot.conflictScore);

      // Detect event triggers
      if(MathAbs(snapshot.alignmentScore - m_currentSnapshot.alignmentScore) >= 0.15)
      {
         SSentinelEvent alignEvt = CConfluenceEvents::CreateAlignmentChangedEvent(snapshot, snapshot.timestamp);
         // Event notification generated
      }

      if(MathAbs(snapshot.conflictScore - m_currentSnapshot.conflictScore) >= 0.15)
      {
         SSentinelEvent conflictEvt = CConfluenceEvents::CreateConflictChangedEvent(snapshot, snapshot.timestamp);
         // Event notification generated
      }

      m_currentSnapshot = snapshot;
      outSnapshot = snapshot;
      return true;
   }

   /// @brief Retrieves the latest evaluated snapshot.
   virtual bool GetSnapshot(SConfluenceSnapshot &outSnapshot) const override
   {
      if(m_currentSnapshot.snapshotId == 0)
         return false;
      outSnapshot = m_currentSnapshot;
      return true;
   }

   /// @brief Retrieves configuration settings.
   virtual SConfluenceConfiguration GetConfiguration() const override
   {
      return m_analyzer.GetConfiguration();
   }

   /// @brief Updates configuration settings.
   virtual void SetConfiguration(const SConfluenceConfiguration &config) override
   {
      m_analyzer.SetConfiguration(config);
   }

   /// @brief Retrieves telemetry statistics.
   virtual SConfluenceStatistics GetStatistics() const override
   {
      return m_stats;
   }

   /// @brief Resets engine state.
   virtual void Reset() override
   {
      m_nextSnapshotId = 1;
      m_sequenceNumber = 0;
      m_currentSnapshot.Reset();
      m_stats.Reset();
      m_repository.Clear();
   }
};
