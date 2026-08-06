//+------------------------------------------------------------------+
//|                                           IMarketStateEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Framework/Context/MarketContext.mqh"
#include "MarketStateSnapshot.mqh"

/// @class IMarketStateEngine
/// @brief Stable public interface contract for the Market State Classification Engine.
class IMarketStateEngine
{
public:
   virtual ~IMarketStateEngine() {}
   virtual bool GetSnapshot(SMarketStateSnapshot &snapshot) const = 0;
   virtual SMarketStateSnapshot GetSnapshot() const = 0;
   virtual void ProcessState(const SMarketContext &context) = 0;
};
