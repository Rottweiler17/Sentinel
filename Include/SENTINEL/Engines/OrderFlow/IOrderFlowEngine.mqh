//+------------------------------------------------------------------+
//|                                              IOrderFlowEngine.mqh|
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Framework/Context/MarketContext.mqh"
#include "OrderFlowSnapshot.mqh"

/// @interface IOrderFlowEngine
/// @brief Stable public interface contract for the Order Flow Approximation Engine.
/// 
/// @note PUBLIC CONTRACT GUARANTEES:
/// 1. Pressure: Estimates framework-derived buying and selling pressure metrics.
/// 2. Initiative: Identifies buyer/seller initiative pressure states.
/// 3. Participation: Evaluates participation score rates.
/// 4. Absorption: Evaluates absorption dynamics.
interface IOrderFlowEngine : public IEngine
{
public:
   virtual const SOrderFlowSnapshot* GetSnapshot() const = 0;
   virtual void ProcessOrderFlow(const SMarketContext &context) = 0;
};
