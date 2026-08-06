//+------------------------------------------------------------------+
//|                                           SentinelAppLogger.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @enum ENUM_LOG_CATEGORY
/// @brief Categorized log level categories.
enum ENUM_LOG_CATEGORY
{
   LOG_CAT_INIT = 0,
   LOG_CAT_RUNTIME,
   LOG_CAT_RENDERING,
   LOG_CAT_VALIDATION,
   LOG_CAT_PERFORMANCE,
   LOG_CAT_EXCEPTION
};

/// @class CSentinelAppLogger
/// @brief Centralized logging & telemetry tracer for Sentinel Developer Application.
class CSentinelAppLogger
{
public:
   /// @brief Logs categorized message to MT5 Experts console.
   static void Log(ENUM_LOG_CATEGORY category, const string &msg)
   {
      string prefix = "";
      switch(category)
      {
         case LOG_CAT_INIT:        prefix = "[SENTINEL-INIT]"; break;
         case LOG_CAT_RUNTIME:     prefix = "[SENTINEL-RUN]"; break;
         case LOG_CAT_RENDERING:   prefix = "[SENTINEL-VIS]"; break;
         case LOG_CAT_VALIDATION:  prefix = "[SENTINEL-VAL]"; break;
         case LOG_CAT_PERFORMANCE: prefix = "[SENTINEL-PERF]"; break;
         case LOG_CAT_EXCEPTION:   prefix = "[SENTINEL-ERROR]"; break;
      }
      Print(StringFormat("%s %s", prefix, msg));
   }

   /// @brief Logs initialization milestone.
   static void LogInitSubsystem(const string &subsystemName, bool success, double durationMs)
   {
      if(success)
         Print(StringFormat("[SENTINEL-INIT] [OK] %-25s Initialized in %.2f ms", subsystemName, durationMs));
      else
         Print(StringFormat("[SENTINEL-INIT] [FAIL] %-25s INITIALIZATION FAILED!", subsystemName));
   }
};
