//+------------------------------------------------------------------+
//|                                               ISessionEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Framework/Context/MarketContext.mqh"
#include "SessionSnapshot.mqh"

/// @class ISessionEngine
/// @brief Stable public interface contract for the Market Session Engine.
class ISessionEngine
{
public:
   virtual ~ISessionEngine() {}
   virtual bool GetSnapshot(SSessionSnapshot &snapshot) const = 0;
   virtual SSessionSnapshot GetSnapshot() const = 0;
   virtual void ProcessSession(const SMarketContext &context) = 0;
};
