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
/// 
/// @note PUBLIC CONTRACT GUARANTEES:
/// 1. Tick Volume: Extracted tick volume and real volume indicators.
/// 2. Relative Volume: RVol ratio (current vs rolling average volume).
/// 3. Vol State: Spike, compression, and dry-up state tracking.
/// 4. Session & Daily Volume: Session/daily accumulated volumes.
interface IVolumeEngine : public IEngine
{
public:
   virtual const SVolumeSnapshot* GetSnapshot() const = 0;
   virtual void ProcessVolume(const SMarketContext &context) = 0;
};
