//+------------------------------------------------------------------+
//|                                         ConfluenceValidator.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "ConfluenceSnapshot.mqh"

/// @class CConfluenceValidator
/// @brief Validation rules checking input context integrity and snapshot validity.
class CConfluenceValidator
{
public:
   /// @brief Validates input MarketContext data freshness and non-zero state.
   static bool ValidateContext(const SMarketContext &context)
   {
      if(context.timestamp == 0)
         return false;
      return true;
   }

   /// @brief Validates output ConfluenceSnapshot bounds.
   static bool ValidateSnapshot(const SConfluenceSnapshot &snapshot)
   {
      if(snapshot.timestamp == 0)
         return false;
      if(snapshot.overallConfluenceScore < -1.0 || snapshot.overallConfluenceScore > 1.0)
         return false;
      if(snapshot.alignmentScore < 0.0 || snapshot.alignmentScore > 1.0)
         return false;
      if(snapshot.conflictScore < 0.0 || snapshot.conflictScore > 1.0)
         return false;
      return true;
   }
};
