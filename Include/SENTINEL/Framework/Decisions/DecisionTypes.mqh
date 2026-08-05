//+------------------------------------------------------------------+
//|                                                DecisionTypes.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @enum ENUM_GENERIC_RECOMMENDATION
/// @brief Strategy-independent recommendations for market environments.
enum ENUM_GENERIC_RECOMMENDATION
{
   RECOMMEND_UNFAVORABLE = 0,
   RECOMMEND_NEUTRAL,
   RECOMMEND_FAVORABLE,
   RECOMMEND_LOW_CONFLUENCE,
   RECOMMEND_HIGH_CONFLUENCE
};
