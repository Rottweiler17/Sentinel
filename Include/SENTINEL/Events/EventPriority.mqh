//+------------------------------------------------------------------+
//|                                                EventPriority.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @enum ENUM_EVENT_PRIORITY
/// @brief Priority tiers for event dispatch ordering.
enum ENUM_EVENT_PRIORITY
{
   EVENT_PRIORITY_LOW = 0,      ///< Background telemetry & stats
   EVENT_PRIORITY_NORMAL,       ///< Regular bar & market updates
   EVENT_PRIORITY_HIGH,         ///< Signals, risk calculations, decisions
   EVENT_PRIORITY_CRITICAL      ///< Real-time ticks & system errors
};
