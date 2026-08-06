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
interface IFVGEngine
{
public:
   virtual bool GetSnapshot(SFVGSnapshot &snapshot) const = 0;
   virtual void ProcessFVGs(const SMarketContext &context) = 0;
};
