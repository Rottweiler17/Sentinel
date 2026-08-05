//+------------------------------------------------------------------+
//|                                                        Types.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "Defs.mqh"

//+------------------------------------------------------------------+
//| Structural Enums                                                |
//+------------------------------------------------------------------+
enum ENUM_SWING_TYPE
{
   SWING_TYPE_NONE = 0,
   SWING_TYPE_HIGH,
   SWING_TYPE_LOW
};

enum ENUM_ZONE_TYPE
{
   ZONE_TYPE_NONE = 0,
   ZONE_TYPE_ORDER_BLOCK_BULL,
   ZONE_TYPE_ORDER_BLOCK_BEAR,
   ZONE_TYPE_FVG_BULL,
   ZONE_TYPE_FVG_BEAR,
   ZONE_TYPE_LIQUIDITY_BUY,
   ZONE_TYPE_LIQUIDITY_SELL,
   ZONE_TYPE_SUPPLY,
   ZONE_TYPE_DEMAND
};

enum ENUM_SIGNAL_TYPE
{
   SIGNAL_NONE = 0,
   SIGNAL_BUY,
   SIGNAL_SELL,
   SIGNAL_CLOSE_BUY,
   SIGNAL_CLOSE_SELL
};

//+------------------------------------------------------------------+
//| Market Data Structs                                             |
//+------------------------------------------------------------------+
struct SBarData
{
   datetime time;
   double   open;
   double   high;
   double   low;
   double   close;
   long     tick_volume;
   int      spread;
   long     real_volume;
};

struct STickData
{
   datetime time;
   double   bid;
   double   ask;
   double   last;
   ulong    volume;
   datetime time_msc;
   uint     flags;
   double   volume_real;
};

struct SSwingPoint
{
   ulong           id;
   datetime        time;
   int             barIndex;
   double          price;
   ENUM_SWING_TYPE type;
   ENUM_TIMEFRAMES timeframe;
   bool            isBroken;
   datetime        breakTime;
};

struct SZoneData
{
   ulong           id;
   ENUM_ZONE_TYPE  type;
   ENUM_TIMEFRAMES timeframe;
   double          topPrice;
   double          bottomPrice;
   datetime        startTime;
   datetime        endTime;
   bool            isMitigated;
   datetime        mitigationTime;
   double          strengthScore;
};

struct SSignalData
{
   ulong            id;
   datetime         time;
   string           symbol;
   ENUM_TIMEFRAMES  timeframe;
   ENUM_SIGNAL_TYPE type;
   double           entryPrice;
   double           stopLoss;
   double           takeProfit;
   double           confidenceScore;
   string           sourceModule;
};
