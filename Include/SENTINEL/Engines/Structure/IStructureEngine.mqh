//+------------------------------------------------------------------+
//|                                             IStructureEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Data/MarketDataSnapshot.mqh"
#include "StructureSnapshot.mqh"

/// @interface IStructureEngine
/// @brief Stable public interface contract for the Market Structure Engine.
/// 
/// @note PUBLIC CONTRACT GUARANTEES:
/// 1. Swings: Emits and caches Major and Minor swing high/low points.
/// 2. BOS: Detects and publishes trend continuation Breaks of Structure (BOS).
/// 3. CHOCH: Detects and publishes trend reversal Change of Character (CHOCH) triggers.
/// 4. Trend: Calculates macro external and micro internal trend directions (Bullish, Bearish, Neutral).
interface IStructureEngine : public IEngine
{
public:
   virtual const SStructureSnapshot* GetSnapshot() const = 0;
   virtual void ProcessStructure(const SMarketDataSnapshot &snapshot) = 0;
   virtual void RegisterSwing(const SSwingPoint &swing) = 0;
};
