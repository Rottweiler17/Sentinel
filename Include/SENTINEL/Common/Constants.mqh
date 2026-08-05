//+------------------------------------------------------------------+
//|                                                    Constants.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

/// @file Constants.mqh
/// @brief Central repository for framework identity, limits, and system-wide default constants.

#define SENTINEL_VERSION               "1.00"
#define SENTINEL_NAME                  "SENTINEL Framework"
#define SENTINEL_COPYRIGHT             "Institutional Trading Architecture"

#define SENTINEL_DEFAULT_BAR_CAPACITY  5000   ///< Default max bars retained per timeframe
#define SENTINEL_DEFAULT_TICK_CAPACITY 10000  ///< Default max ticks stored in ring buffer
#define SENTINEL_MAX_MODULES           64     ///< Maximum active strategy modules
#define SENTINEL_MAX_ENGINES           32     ///< Maximum registered core engines
#define SENTINEL_OBJECT_POOL_SIZE      500    ///< Default object pool capacity
#define SENTINEL_OBJECT_POOL_CHUNK     32     ///< Object pool growth chunk size

/// @enum ENUM_SENTINEL_STATUS
/// @brief Standardized status codes returned by framework operations.
enum ENUM_SENTINEL_STATUS
{
   SENTINEL_SUCCESS = 0,               ///< Operation completed successfully
   SENTINEL_ERR_INVALID_PARAM,         ///< Invalid argument or parameter supplied
   SENTINEL_ERR_OUT_OF_MEMORY,         ///< Allocation failure or memory limit exceeded
   SENTINEL_ERR_NOT_FOUND,             ///< Requested entity or key not found
   SENTINEL_ERR_ALREADY_EXISTS,        ///< Entity already exists in registry
   SENTINEL_ERR_INITIALIZATION_FAILED, ///< Component failed to initialize
   SENTINEL_ERR_NOT_INITIALIZED,       ///< Component called before initialization
   SENTINEL_ERR_MODULE_REGISTER_FAILED,///< Plugin registration failed
   SENTINEL_ERR_SYNC_TIMEOUT,          ///< Historical data sync timed out
   SENTINEL_ERR_BUFFER_OVERFLOW,       ///< Fixed capacity ring buffer overflowed
   SENTINEL_ERR_NULL_POINTER           ///< Unexpected null pointer encountered
};

#define SAFE_DELETE(ptr) if(CheckPointer(ptr) == POINTER_DYNAMIC) { delete ptr; ptr = NULL; }
#define IS_VALID_POINTER(ptr) (CheckPointer(ptr) != POINTER_INVALID)
