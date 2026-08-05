//+------------------------------------------------------------------+
//|                                             ILiquidityEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Data/MarketDataSnapshot.mqh"
#include "../Structure/StructureSnapshot.mqh"
#include "LiquiditySnapshot.mqh"

/// @interface ILiquidityEngine
/// @brief Stable public interface contract for the Institutional Liquidity Engine.
interface ILiquidityEngine : public IEngine
{
public:
   virtual const SLiquiditySnapshot* GetSnapshot() const = 0;
   virtual void ProcessLiquidity(const SMarketDataSnapshot &marketSnap, const SStructureSnapshot &structSnap) = 0;
 };
