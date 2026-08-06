//+------------------------------------------------------------------+
//|                                              IOrderBlockEngine.mqh|
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Framework/Context/MarketContext.mqh"
#include "OrderBlockSnapshot.mqh"

/// @class IOrderBlockEngine
/// @brief Stable public interface contract for the Order Block detection module.
class IOrderBlockEngine
{
public:
   virtual ~IOrderBlockEngine() {}
   virtual bool GetSnapshot(SOrderBlockSnapshot &snapshot) const = 0;
   virtual void ProcessOrderBlocks(const SMarketContext &context) = 0;
};
