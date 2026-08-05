//+------------------------------------------------------------------+
//|                                               IVolumeEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Framework/Context/MarketContext.mqh"
#include "VolumeSnapshot.mqh"

/// @interface IVolumeEngine
/// @brief Stable public interface contract for the Volume Analysis Engine.
interface IVolumeEngine : public IEngine
{
public:
   virtual const SVolumeSnapshot* GetSnapshot() const = 0;
   virtual void ProcessVolume(const SMarketContext &context) = 0;
};
