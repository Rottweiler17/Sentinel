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
/// 
/// @note PUBLIC CONTRACT GUARANTEES:
/// 1. Liquidity Pools: Detects and caches active and consumed resting BSL and SSL pools.
/// 2. Equal Highs/Lows: Identifies double top/bottom (EQH/EQL) patterns within configured tolerances.
/// 3. Sweeps: Detects Bullish, Bearish, Partial, and Complete liquidity sweeps.
/// 4. Classification: Classifies pool significance levels (Weak to Institutional).
interface ILiquidityEngine : public IEngine
{
public:
   virtual const SLiquiditySnapshot* GetSnapshot() const = 0;
   virtual void ProcessLiquidity(const SMarketDataSnapshot &marketSnap, const SStructureSnapshot &structSnap) = 0;
};
