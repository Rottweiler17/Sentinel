//+------------------------------------------------------------------+
//|                                         ICTValidationTypes.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @enum ENUM_ICT_CONDITION
/// @brief 8 core conditions evaluated by the ICT Strategy Validation Pack.
enum ENUM_ICT_CONDITION
{
   ICT_COND_MARKET_STRUCTURE_SHIFT = 0,
   ICT_COND_LIQUIDITY_SWEEP,
   ICT_COND_ORDER_BLOCK_PRESENT,
   ICT_COND_FVG_PRESENT,
   ICT_COND_KILLZONE_SESSION,
   ICT_COND_MARKET_STATE,
   ICT_COND_CONFLUENCE_SCORE,
   ICT_COND_DECISION_SCORE,
   ICT_CONDITION_COUNT
};

/// @struct SICTConditionResult
/// @brief Struct representing single ICT condition evaluation result.
struct SICTConditionResult
{
   ENUM_ICT_CONDITION condition;
   bool               satisfied;
   double             weight;
   double             score;
   string             description;

   void Reset()
   {
      condition   = ICT_COND_MARKET_STRUCTURE_SHIFT;
      satisfied   = false;
      weight      = 1.0;
      score       = 0.0;
      description = "";
   }
};
