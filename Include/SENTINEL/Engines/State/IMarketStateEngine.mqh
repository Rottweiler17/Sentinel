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
interface IMarketStateEngine : public IEngine
{
public:
   virtual const SMarketStateSnapshot* GetSnapshot() const = 0;
   virtual void ProcessState(const SMarketContext &context) = 0;
};
