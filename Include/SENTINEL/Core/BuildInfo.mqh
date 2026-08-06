//+------------------------------------------------------------------+
//|                                                    BuildInfo.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "Version.mqh"

/// @file BuildInfo.mqh
/// @brief Centralized build metadata repository for Project SENTINEL.

#define SENTINEL_FRAMEWORK_NAME         "SENTINEL Framework"
#define SENTINEL_BUILD_DATE             __DATE__
#define SENTINEL_BUILD_TIME             __DATETIME__
#define SENTINEL_COMPATIBILITY_VERSION  "1.0.0"
#define SENTINEL_BUILD_NUMBER           1001

/// @class CBuildInfo
/// @brief Programmatic interface for retrieving build metadata.
class CBuildInfo
{
public:
   static string FrameworkName()        { return SENTINEL_FRAMEWORK_NAME; }
   static string BuildDate()            { return TimeToString(SENTINEL_BUILD_DATE, TIME_DATE); }
   static string BuildTime()            { return TimeToString(SENTINEL_BUILD_TIME, TIME_MINUTES); }
   static string CompatibilityVersion() { return SENTINEL_COMPATIBILITY_VERSION; }
   static int    BuildNumber()          { return SENTINEL_BUILD_NUMBER; }
   static string FullVersionInfo()
   {
      return StringFormat("%s v%s (Build %d, %s %s)", 
                          SENTINEL_FRAMEWORK_NAME, 
                          SENTINEL_VERSION_STRING, 
                          SENTINEL_BUILD_NUMBER, 
                          TimeToString(SENTINEL_BUILD_DATE, TIME_DATE), 
                          TimeToString(SENTINEL_BUILD_TIME, TIME_MINUTES));
   }
};
