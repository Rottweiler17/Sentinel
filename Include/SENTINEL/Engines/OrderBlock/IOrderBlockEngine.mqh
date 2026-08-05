//+------------------------------------------------------------------+
//|                                              IOrderBlockEngine.mqh|
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Framework/Context/MarketContext.mqh"
#include "OrderBlockSnapshot.mqh"

/// @interface IOrderBlockEngine
/// @brief Stable public interface contract for the Order Block detection module.
/// 
/// @note PUBLIC CONTRACT GUARANTEES:
/// 1. Detection: Scans market structure breaks to discover supply/demand order blocks.
/// 2. Lifecycle: Transitions states (Created, Validated, Active, Retested, Mitigated, Expired).
/// 3. Levels: Publishes upper, lower, and mid prices for each block.
interface IOrderBlockEngine : public IEngine
{
public:
   virtual const SOrderBlockSnapshot* GetSnapshot() const = 0;
   virtual void ProcessOrderBlocks(const SMarketContext &context) = 0;
};
