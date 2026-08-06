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
interface IOrderBlockEngine
{
public:
   virtual bool GetSnapshot(SOrderBlockSnapshot &snapshot) const = 0;
   virtual void ProcessOrderBlocks(const SMarketContext &context) = 0;
};
