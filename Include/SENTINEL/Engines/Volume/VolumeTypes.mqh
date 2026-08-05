//+------------------------------------------------------------------+
//|                                                  VolumeTypes.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @enum ENUM_VOLUME_TREND
/// @brief Directional classification of volume momentum.
enum ENUM_VOLUME_TREND
{
   VOLUME_TREND_STABLE = 0,
   VOLUME_TREND_INCREASING,
   VOLUME_TREND_DECREASING
};

/// @enum ENUM_VOLUME_STATE
/// @brief Status classifications for volume behavior.
enum ENUM_VOLUME_STATE
{
   VOLUME_STATE_NORMAL = 0,
   VOLUME_STATE_SPIKE,
   VOLUME_STATE_COMPRESSION,
   VOLUME_STATE_EXPANSION,
   VOLUME_STATE_DRYUP
};
