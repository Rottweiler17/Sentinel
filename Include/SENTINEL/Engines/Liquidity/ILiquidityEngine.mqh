//+------------------------------------------------------------------+
//|                                             ILiquidityEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Data/MarketDataSnapshot.mqh"
#include "../Structure/StructureSnapshot.mqh"
#include "LiquiditySnapshot.mqh"

/// @class ILiquidityEngine
/// @brief Stable public interface contract for the Institutional Liquidity Engine.
class ILiquidityEngine
{
public:
   virtual ~ILiquidityEngine() {}
   virtual bool GetSnapshot(SLiquiditySnapshot &snapshot) const = 0;
   virtual SLiquiditySnapshot GetSnapshot() const = 0;
   virtual void ProcessLiquidity(const SMarketDataSnapshot &marketSnap, const SStructureSnapshot &structSnap) = 0;
};
