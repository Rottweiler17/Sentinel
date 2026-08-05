//+------------------------------------------------------------------+
//|                                                          IZoneEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Data/MarketDataSnapshot.mqh"
#include "../../Engines/Structure/StructureSnapshot.mqh"
#include "../../Engines/Liquidity/LiquiditySnapshot.mqh"
#include "ZoneSnapshot.mqh"

/// @interface IZoneEngine
/// @brief Stable public interface contract for the Generic Zone Framework Engine.
/// 
/// @note PUBLIC CONTRACT GUARANTEES:
/// 1. Support & Resistance: Creates generic zones from swing highs/lows.
/// 2. Lifecycle: Transitions zone states (Created, Validated, Active, Retested, Merged, Mitigated, Consumed, Expired).
/// 3. Overlap Merging: Consolidates overlapping zones based on configurable overlap tolerances.
/// 4. Lookup: Fast O(1) repository queries.
interface IZoneEngine : public IEngine
{
public:
   virtual const SZoneSnapshot* GetSnapshot() const = 0;
   virtual void ProcessZones(const SMarketDataSnapshot &marketSnap, 
                             const SStructureSnapshot &structSnap, 
                             const SLiquiditySnapshot &liqSnap) = 0;
   virtual bool RegisterZone(SGenericZone &zone, double pointVal) = 0;
};
