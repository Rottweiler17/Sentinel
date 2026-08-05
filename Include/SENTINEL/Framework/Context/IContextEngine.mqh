//+------------------------------------------------------------------+
//|                                              IContextEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "MarketContext.mqh"

/// @interface IContextEngine
/// @brief Stable public interface contract for the Unified Market Context Engine.
interface IContextEngine : public IEngine
{
public:
   virtual const SMarketContext* GetContext() const = 0;
   virtual void UpdateContext(const SMarketDataSnapshot &marketSnap,
                              const SStructureSnapshot &structSnap,
                              const SLiquiditySnapshot &liqSnap,
                              const SZoneSnapshot &zoneSnap,
                              const SSessionSnapshot &sessionSnap,
                              const SMarketStateSnapshot &stateSnap,
                              const SVolumeSnapshot &volumeSnap,
                              const SOrderFlowSnapshot &orderFlowSnap,
                              const SFeatureSnapshot &featuresSnap,
                              const SDecisionSnapshot &decisionsSnap) = 0;
};
