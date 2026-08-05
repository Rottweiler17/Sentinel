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
interface IZoneEngine : public IEngine
{
public:
   virtual const SZoneSnapshot* GetSnapshot() const = 0;
   virtual void ProcessZones(const SMarketDataSnapshot &marketSnap, 
                             const SStructureSnapshot &structSnap, 
                             const SLiquiditySnapshot &liqSnap) = 0;
   virtual bool RegisterZone(SGenericZone &zone, double pointVal) = 0;
};
