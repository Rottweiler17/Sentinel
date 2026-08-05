//+------------------------------------------------------------------+
//|                                             OrderBlockTypes.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @enum ENUM_ORDERBLOCK_DIRECTION
/// @brief Direction of order block levels.
enum ENUM_ORDERBLOCK_DIRECTION
{
   ORDERBLOCK_BULLISH = 0,
   ORDERBLOCK_BEARISH
};

/// @enum ENUM_ORDERBLOCK_LIFECYCLE
/// @brief Lifecycle tracking state for order blocks.
enum ENUM_ORDERBLOCK_LIFECYCLE
{
   ORDERBLOCK_STATE_CREATED = 0,
   ORDERBLOCK_STATE_VALIDATED,
   ORDERBLOCK_STATE_ACTIVE,
   ORDERBLOCK_STATE_RETESTED,
   ORDERBLOCK_STATE_MITIGATED,
   ORDERBLOCK_STATE_INVALIDATED,
   ORDERBLOCK_STATE_EXPIRED
};

/// @struct SOrderBlock
/// @brief Structure representing a concrete detected order block zone.
struct SOrderBlock
{
   ulong                     id;
   ENUM_ORDERBLOCK_DIRECTION direction;
   datetime                  creationTime;
   
   double                    upperPrice;
   double                    lowerPrice;
   double                    midPrice;
   
   double                    strength;          ///< 0.0 to 100.0%
   double                    confidence;        ///< 0.0 to 100.0%
   double                    freshness;         ///< 0.0 to 100.0%
   int                       retestCount;
   bool                      isMitigated;
   ENUM_ORDERBLOCK_LIFECYCLE lifecycleState;
};
