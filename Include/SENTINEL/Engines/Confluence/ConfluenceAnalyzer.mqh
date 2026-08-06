//+------------------------------------------------------------------+
//|                                           ConfluenceAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "ConfluenceSnapshot.mqh"
#include "ConfluenceConfiguration.mqh"
#include "EvidenceAggregator.mqh"
#include "ConfluenceCalculator.mqh"

/// @class CConfluenceAnalyzer
/// @brief Primary analytical engine component coordinating evidence extraction and synthesis.
class CConfluenceAnalyzer
{
private:
   SConfluenceConfiguration m_config;

public:
   CConfluenceAnalyzer()
   {
      m_config.SetDefaults();
   }

   /// @brief Updates configuration settings.
   void SetConfiguration(const SConfluenceConfiguration &config)
   {
      m_config = config;
   }

   /// @brief Gets current configuration.
   SConfluenceConfiguration GetConfiguration() const
   {
      return m_config;
   }

   /// @brief Analyzes input MarketContext and constructs an immutable ConfluenceSnapshot.
   bool Analyze(const SMarketContext &context, SConfluenceSnapshot &outSnapshot)
   {
      outSnapshot.Reset();
      outSnapshot.timestamp = context.timestamp;

      // 1. Aggregate Evidence
      CEvidenceAggregator::AggregateEvidence(context, m_config, outSnapshot.evidenceList);

      // 2. Perform Confluence Synthesis
      CConfluenceCalculator::Calculate(outSnapshot.evidenceList, m_config, outSnapshot);

      return true;
   }
};
