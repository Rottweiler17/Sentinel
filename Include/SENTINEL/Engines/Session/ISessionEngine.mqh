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
interface ISessionEngine : public IEngine
{
public:
   virtual const SSessionSnapshot* GetSnapshot() const = 0;
   virtual void ProcessSession(const SMarketContext &context) = 0;
};
