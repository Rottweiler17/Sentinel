//+------------------------------------------------------------------+
//|                                                    TimeUtils.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "../Core/Types.mqh"

class CTimeUtils
{
public:
   static ENUM_SESSION_TYPE GetCurrentSession(datetime time)
   {
      MqlDateTime dt;
      TimeToStruct(time, dt);

      int hour = dt.hour;

      // Asian Session: 00:00 - 08:00 GMT
      if(hour >= 0 && hour < 8)
         return SESSION_ASIAN;

      // London Session: 07:00 - 16:00 GMT
      if(hour >= 8 && hour < 13)
      {
         if(hour >= 8 && hour <= 10)
            return SESSION_LONDON_KILLZONE;
         return SESSION_LONDON;
      }

      // NY Session: 12:00 - 21:00 GMT
      if(hour >= 13 && hour < 21)
      {
         if(hour >= 13 && hour <= 15)
            return SESSION_NY_KILLZONE;
         return SESSION_NEW_YORK;
      }

      return SESSION_NONE;
   }

   static datetime RoundToBarTime(datetime time, ENUM_TIMEFRAMES tf)
   {
      int periodSeconds = PeriodSeconds(tf);
      if(periodSeconds <= 0) return time;
      return (datetime)((time / periodSeconds) * periodSeconds);
   }

   static bool IsNewBar(datetime lastBarTime, datetime currentTickTime, ENUM_TIMEFRAMES tf)
   {
      datetime currentBarTime = RoundToBarTime(currentTickTime, tf);
      return (currentBarTime > lastBarTime);
   }
};
