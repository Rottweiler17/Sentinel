//+------------------------------------------------------------------+
//|                                                EventCategory.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @enum ENUM_EVENT_CATEGORY
/// @brief High-level classification of events for subscription filtering.
enum ENUM_EVENT_CATEGORY
{
   EVENT_CATEGORY_SYSTEM = 0,   ///< Infrastructure & configuration events
   EVENT_CATEGORY_MARKET,       ///< Real-time price, tick, bar & volume events
   EVENT_CATEGORY_TRADING,      ///< Confluence, decision & signal events
   EVENT_CATEGORY_UI            ///< GUI & dashboard user interaction events
};
