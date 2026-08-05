//+------------------------------------------------------------------+
//|                                           InitiativeAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "OrderFlowTypes.mqh"

/// @class CInitiativeAnalyzer
/// @brief Identifies dynamic market buyer/seller initiative pressure states.
class CInitiativeAnalyzer
{
public:
   static ENUM_INITIATIVE_TYPE AnalyzeInitiative(const SMarketContext &context, double buyPress)
   {
      if(buyPress > 55.0) return INITIATIVE_BUYER;
      if(buyPress < 45.0) return INITIATIVE_SELLER;
      return INITIATIVE_NONE;
   }
};
