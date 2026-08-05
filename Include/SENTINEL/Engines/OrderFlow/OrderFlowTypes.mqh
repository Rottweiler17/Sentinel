//+------------------------------------------------------------------+
//|                                               OrderFlowTypes.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @enum ENUM_INITIATIVE_TYPE
/// @brief Classification of market aggression/initiative.
enum ENUM_INITIATIVE_TYPE
{
   INITIATIVE_NONE = 0,
   INITIATIVE_BUYER,
   INITIATIVE_SELLER
};

/// @enum ENUM_ABSORPTION_STATE
/// @brief Estimated absorption dynamics.
enum ENUM_ABSORPTION_STATE
{
   ABSORPTION_NONE = 0,
   ABSORPTION_BULLISH,
   ABSORPTION_BEARISH
};
