//+------------------------------------------------------------------+
//|                                                     LogLevel.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @enum ENUM_LOG_LEVEL
/// @brief Severity tiers for system diagnostic logging.
enum ENUM_LOG_LEVEL
{
   LOG_LEVEL_DEBUG = 0,
   LOG_LEVEL_INFO,
   LOG_LEVEL_WARN,
   LOG_LEVEL_ERROR,
   LOG_LEVEL_OFF
};
