//+------------------------------------------------------------------+
//|                                                   IFVGEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Framework/Context/MarketContext.mqh"
#include "FVGSnapshot.mqh"

/// @interface IFVGEngine
/// @brief Stable public interface contract for the Fair Value Gap detection engine module.
/// 
/// @note PUBLIC CONTRACT GUARANTEES:
/// 1. Detection: Scans candle high/low limits to resolve bullish and bearish imbalances (FVGs).
/// 2. Lifecycle: Transitions states (Created, Validated, Active, Partially Filled, Completely Filled, Invalidated, Expired).
/// 3. Levels: Tracks gap upper boundaries, lower boundaries, size, and fill percentages.
interface IFVGEngine : public IEngine
{
public:
   virtual const SFVGSnapshot* GetSnapshot() const = 0;
   virtual void ProcessFVGs(const SMarketContext &context) = 0;
};
