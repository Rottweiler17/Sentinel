//+------------------------------------------------------------------+
//|                                               ISessionEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Framework/Context/MarketContext.mqh"
#include "SessionSnapshot.mqh"

/// @interface ISessionEngine
/// @brief Stable public interface contract for the Market Session Engine.
/// 
/// @note PUBLIC CONTRACT GUARANTEES:
/// 1. Session State: Tracks Asian, London, New York, Sydney sessions and overlaps.
/// 2. Intraday Stats: Computes session highs, lows, midpoint, and range parameters.
/// 3. Reference Levels: Publishes Previous Day/Week/Month Highs and Lows and current Day/Week/Month opens.
interface ISessionEngine : public IEngine
{
public:
   virtual const SSessionSnapshot* GetSnapshot() const = 0;
   virtual void ProcessSession(const SMarketContext &context) = 0;
};
