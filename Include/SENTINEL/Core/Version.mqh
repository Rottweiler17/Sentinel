//+------------------------------------------------------------------+
//|                                                      Version.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @file Version.mqh
/// @brief Centralized version specification for Project SENTINEL.

#define SENTINEL_VERSION_MAJOR     1
#define SENTINEL_VERSION_MINOR     0
#define SENTINEL_VERSION_PATCH     0

#define SENTINEL_VERSION_STRING    "1.0.0"

/// @class CVersion
/// @brief Helper class providing programmatic access to version information.
class CVersion
{
public:
   static int Major() { return SENTINEL_VERSION_MAJOR; }
   static int Minor() { return SENTINEL_VERSION_MINOR; }
   static int Patch() { return SENTINEL_VERSION_PATCH; }
   static string ToString() { return SENTINEL_VERSION_STRING; }
};
