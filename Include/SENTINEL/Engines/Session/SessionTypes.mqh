//+------------------------------------------------------------------+
//|                                                 SessionTypes.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @enum ENUM_MARKET_SESSION
/// @brief Major global trading sessions.
enum ENUM_MARKET_SESSION
{
   SESSION_UNKNOWN = 0,
   SESSION_ASIAN,
   SESSION_LONDON,
   SESSION_NEWYORK,
   SESSION_SYDNEY,
   SESSION_OVERLAP_LDN_NY,
   SESSION_OVERLAP_ASIA_LDN
};

/// @struct SSessionStats
/// @brief Live price statistics tracked per session.
struct SSessionStats
{
   double   high;
   double   low;
   double   midpoint;
   double   range;
   double   openPrice;
   double   closePrice;
   datetime highTime;
   datetime lowTime;
};

/// @struct SReferenceLevels
/// @brief Key historical reference price levels.
struct SReferenceLevels
{
   double prevDayHigh;
   double prevDayLow;
   double prevWeekHigh;
   double prevWeekLow;
   double prevMonthHigh;
   double prevMonthLow;
   double currentDayOpen;
   double currentWeekOpen;
   double currentMonthOpen;
};
