//+------------------------------------------------------------------+
//|                                             OrderFlowAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "OrderFlowTypes.mqh"
#include "OrderFlowConfiguration.mqh"
#include "PressureAnalyzer.mqh"
#include "ParticipationAnalyzer.mqh"
#include "InitiativeAnalyzer.mqh"
#include "AbsorptionEstimator.mqh"

/// @class COrderFlowAnalyzer
/// @brief Orchestrates estimation of pressure, initiative, absorption, and participation scores.
class COrderFlowAnalyzer
{
public:
   static void ProcessAnalysis(const SMarketContext &context,
                               const COrderFlowConfiguration &config,
                               double &buyPress,
                               double &sellPress,
                               double &bal,
                               double &partScore,
                               ENUM_INITIATIVE_TYPE &init,
                               ENUM_ABSORPTION_STATE &abs,
                               double &aggression)
   {
      // 1. Calculate pressure values
      CPressureAnalyzer::AnalyzePressure(context, buyPress, sellPress);
      bal = (sellPress > 0.0) ? buyPress / sellPress : buyPress;

      // 2. Evaluate participation levels
      partScore = CParticipationAnalyzer::EstimateParticipation(context);

      // 3. Resolve buyer/seller initiative
      init = CInitiativeAnalyzer::AnalyzeInitiative(context, buyPress);

      // 4. Estimate absorption
      abs = CAbsorptionEstimator::EstimateAbsorption(context);

      // 5. Estimate aggression percentage
      aggression = partScore * 0.8;
   }
};
