//+------------------------------------------------------------------+
//|                                           IMarketStateEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Framework/Context/MarketContext.mqh"
#include "MarketStateSnapshot.mqh"

/// @interface IMarketStateEngine
/// @brief Stable public interface contract for the Market State Classification Engine.
/// 
/// @note PUBLIC CONTRACT GUARANTEES:
/// 1. State Classification: Resolves exact environment codes (Trending, Range, Accumulation, Post-Sweep).
/// 2. Metrics: Provides confidence, strength, and volatility ratings.
/// 3. Transitions: Signals environment state change triggers.
interface IMarketStateEngine : public IEngine
{
public:
   virtual const SMarketStateSnapshot* GetSnapshot() const = 0;
   virtual void ProcessState(const SMarketContext &context) = 0;
};
