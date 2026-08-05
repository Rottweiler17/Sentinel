//+------------------------------------------------------------------+
//|                                               IDecisionEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Framework/Context/MarketContext.mqh"
#include "DecisionSnapshot.mqh"

/// @interface IDecisionEngine
/// @brief Stable public interface contract for the Decision Evaluation Engine.
/// 
/// @note PUBLIC CONTRACT GUARANTEES:
/// 1. Confluence: Measures overall agreement across trend, liquidity, zones, and volume.
/// 2. Evaluation: Calculates multi-dimensional quality scores.
/// 3. Recommendations: Derives generic Favorability ratings (Favorable, Neutral, Unfavorable).
interface IDecisionEngine : public IEngine
{
public:
   virtual const SDecisionSnapshot* GetSnapshot() const = 0;
   virtual void ProcessDecision(const SFeatureSnapshot &features) = 0;
};
