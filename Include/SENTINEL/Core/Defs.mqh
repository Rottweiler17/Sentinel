//+------------------------------------------------------------------+
//|                                                         Defs.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

//+------------------------------------------------------------------+
//| Framework Identity & Versioning                                 |
//+------------------------------------------------------------------+
#define SENTINEL_VERSION               "1.00"
#define SENTINEL_NAME                  "SENTINEL Trading Analysis Framework"
#define SENTINEL_COPYRIGHT             "Institutional Quantitative Architecture"

//+------------------------------------------------------------------+
//| Performance & Buffer Limits                                     |
//+------------------------------------------------------------------+
#define SENTINEL_DEFAULT_BAR_CAPACITY  5000   // Max bars cached per timeframe
#define SENTINEL_DEFAULT_TICK_CAPACITY 10000  // Max ticks cached in ring buffer
#define SENTINEL_MAX_MODULES           64     // Max dynamic strategy modules
#define SENTINEL_MAX_ENGINES           32     // Max active engines
#define SENTINEL_OBJECT_POOL_SIZE      500    // Recyclable MT5 graphic elements

//+------------------------------------------------------------------+
//| System Status & Error Codes                                     |
//+------------------------------------------------------------------+
enum ENUM_SENTINEL_STATUS
{
   SENTINEL_SUCCESS = 0,
   SENTINEL_ERR_INVALID_PARAM,
   SENTINEL_ERR_OUT_OF_MEMORY,
   SENTINEL_ERR_NOT_FOUND,
   SENTINEL_ERR_ALREADY_EXISTS,
   SENTINEL_ERR_INITIALIZATION_FAILED,
   SENTINEL_ERR_NOT_INITIALIZED,
   SENTINEL_ERR_MODULE_REGISTER_FAILED,
   SENTINEL_ERR_SYNC_TIMEOUT,
   SENTINEL_ERR_BUFFER_OVERFLOW,
   SENTINEL_ERR_NULL_POINTER
};

//+------------------------------------------------------------------+
//| Utility & Pointer Safety Macros                                 |
//+------------------------------------------------------------------+
#define SAFE_DELETE(ptr) if(CheckPointer(ptr) == POINTER_DYNAMIC) { delete ptr; ptr = NULL; }
#define IS_VALID_POINTER(ptr) (CheckPointer(ptr) != POINTER_INVALID)
#define UNUSED_PARAM(param) (void)(param)
