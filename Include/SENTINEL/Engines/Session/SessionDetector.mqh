//+------------------------------------------------------------------+
//|                                              SessionDetector.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "SessionTypes.mqh"
#include "SessionConfiguration.mqh"

/// @class CSessionDetector
/// @brief Detects active trading session and overlaps based on current broker timestamp.
class CSessionDetector
{
public:
   /// @brief Evaluates session type from current hour.
   static ENUM_MARKET_SESSION DetectSession(datetime timeVal, const CSessionConfiguration &config)
   {
      MqlDateTime dt;
      TimeToStruct(timeVal, dt);
      int hour = dt.hour;

      // 1. London - New York Overlap (usually 13:00 to 16:00 GMT depending on offset)
      if(hour >= config.NewYorkStart() && hour < config.LondonEnd())
         return SESSION_OVERLAP_LDN_NY;

      // 2. Asian - London Overlap
      if(hour >= config.LondonStart() && hour < config.AsianEnd())
         return SESSION_OVERLAP_ASIA_LDN;

      // 3. New York Session
      if(hour >= config.NewYorkStart() || hour < config.NewYorkEnd())
      {
         if(config.NewYorkStart() < config.NewYorkEnd())
         {
            if(hour >= config.NewYorkStart() && hour < config.NewYorkEnd()) return SESSION_NEWYORK;
         }
         else
         {
            if(hour >= config.NewYorkStart() || hour < config.NewYorkEnd()) return SESSION_NEWYORK;
         }
      }

      // 4. London Session
      if(hour >= config.LondonStart() && hour < config.LondonEnd())
         return SESSION_LONDON;

      // 5. Asian Session
      if(hour >= config.AsianStart() && hour < config.AsianEnd())
         return SESSION_ASIAN;

      // 6. Sydney Session
      if(hour >= config.SydneyStart() || hour < config.SydneyEnd())
      {
         if(config.SydneyStart() < config.SydneyEnd())
         {
            if(hour >= config.SydneyStart() && hour < config.SydneyEnd()) return SESSION_SYDNEY;
         }
         else
         {
            if(hour >= config.SydneyStart() || hour < config.SydneyEnd()) return SESSION_SYDNEY;
         }
      }

      return SESSION_UNKNOWN;
   }
};
