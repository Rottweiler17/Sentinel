//+------------------------------------------------------------------+
//|                                           IConfluenceEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "ConfluenceSnapshot.mqh"
#include "ConfluenceConfiguration.mqh"
#include "ConfluenceStatistics.mqh"

/// @interface IConfluenceEngine
/// @brief Contract interface for Confluence Engine implementations.
class IConfluenceEngine
{
public:
   virtual ~IConfluenceEngine() {}

   virtual bool                     Evaluate(const SMarketContext &context, SConfluenceSnapshot &outSnapshot) = 0;
   virtual bool                     GetSnapshot(SConfluenceSnapshot &outSnapshot) const = 0;
   virtual SConfluenceConfiguration GetConfiguration() const = 0;
   virtual void                     SetConfiguration(const SConfluenceConfiguration &config) = 0;
   virtual SConfluenceStatistics   GetStatistics() const = 0;
   virtual void                     Reset() = 0;
};
