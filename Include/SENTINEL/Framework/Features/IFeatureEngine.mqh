//+------------------------------------------------------------------+
//|                                               IFeatureEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Framework/Context/MarketContext.mqh"
#include "FeatureSnapshot.mqh"

/// @interface IFeatureEngine
/// @brief Stable public interface contract for the Feature Engineering Engine.
/// 
/// @note PUBLIC CONTRACT GUARANTEES:
/// 1. Standardization: Converts structure, liquidity, zones, sessions, volume, and order flow into numerical formats.
/// 2. Normalization: Automatically bounds raw vectors to targeted min/max ranges.
/// 3. Metadata: Includes source metrics, timestamps, and confidence percentages.
interface IFeatureEngine : public IEngine
{
public:
   virtual const SFeatureSnapshot* GetSnapshot() const = 0;
   virtual void ProcessFeatures(const SMarketContext &context) = 0;
};
