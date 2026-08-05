//+------------------------------------------------------------------+
//|                                                        Types.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "../Common/Constants.mqh"

/// @enum ENUM_SWING_TYPE
/// @brief Identifies swing structural points.
enum ENUM_SWING_TYPE
{
   SWING_TYPE_NONE = 0,
   SWING_TYPE_HIGH,
   SWING_TYPE_LOW
};

/// @enum ENUM_ZONE_TYPE
/// @brief Identifies Order Block, FVG, Liquidity, and Supply/Demand zone types.
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

/// @enum ENUM_SIGNAL_TYPE
/// @brief Actionable trade setup signal direction.
enum ENUM_SIGNAL_TYPE
{
   SIGNAL_NONE = 0,
   SIGNAL_BUY,
   SIGNAL_SELL,
   SIGNAL_CLOSE_BUY,
   SIGNAL_CLOSE_SELL
};

/// @enum ENUM_REGIME_TYPE
/// @brief Market condition and volatility classification.
enum ENUM_REGIME_TYPE
{
   REGIME_UNKNOWN = 0,
   REGIME_BULLISH_TREND,
   REGIME_BEARISH_TREND,
   REGIME_RANGING,
   REGIME_EXPANSION,
   REGIME_COMPRESSION,
   REGIME_HIGH_VOLATILITY,
   REGIME_LOW_VOLATILITY
};

/// @enum ENUM_SESSION_TYPE
/// @brief Trading session windows and Killzone periods.
enum ENUM_SESSION_TYPE
{
   SESSION_NONE = 0,
   SESSION_ASIAN,
   SESSION_LONDON,
   SESSION_NEW_YORK,
   SESSION_LONDON_KILLZONE,
   SESSION_NY_KILLZONE
};

/// @struct SBarData
/// @brief Price, volume, and spread metrics for a single OHLC candle.
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

/// @struct STickData
/// @brief Real-time tick data wrapper with microsecond precision.
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

/// @struct SSwingPoint
/// @brief Identified swing high or swing low structural pivot point.
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

/// @struct SZoneData
/// @brief Order Block, FVG, or Supply/Demand zone boundary data.
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

/// @struct SSignalData
/// @brief Actionable setup signal emitted by SignalEngine.
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

/// @struct SMarketRegimeData
/// @brief State payload emitted by MarketRegimeEngine.
struct SMarketRegimeData
{
   ENUM_REGIME_TYPE primaryRegime;
   ENUM_REGIME_TYPE volatilityRegime;
   double           atrValue;
   double           adxValue;
   double           trendStrength;
   datetime         lastUpdated;
};

/// @struct SSessionData
/// @brief State payload emitted by SessionEngine.
struct SSessionData
{
   ENUM_SESSION_TYPE currentSession;
   bool              isKillzoneActive;
   double            openingRangeHigh;
   double            openingRangeLow;
   double            pdh;
   double            pdl;
   double            pwh;
   double            pwl;
   double            pmh;
   double            pml;
};

/// @struct SRiskData
/// @brief Position sizing and risk payload emitted by RiskEngine.
struct SRiskData
{
   double accountBalance;
   double riskPercent;
   double maxDrawdownLimit;
   double calculatedLotSize;
   double stopLossPips;
   double takeProfitPips;
   double expectedRMultiple;
   double breakEvenPrice;
};

/// @struct SVolumeProfileData
/// @brief Value area and POC payload emitted by VolumeProfileEngine.
struct SVolumeProfileData
{
   double pocPrice;
   double vahPrice;
   double valPrice;
   double totalVolume;
};

/// @struct SDeltaData
/// @brief Buyer vs seller volume imbalance emitted by DeltaEngine.
struct SDeltaData
{
   double buyVolume;
   double sellVolume;
   double cumulativeDelta;
   double deltaImbalancePercent;
};

/// @struct SAbsorptionData
/// @brief Passive volume barrier detection payload emitted by AbsorptionEngine.
struct SAbsorptionData
{
   double   priceLevel;
   double   absorbedVolume;
   datetime detectionTime;
   bool     isBullishAbsorption;
};

/// @struct SDecisionData
/// @brief Quantitative execution decision payload emitted by DecisionEngine.
struct SDecisionData
{
   ENUM_SIGNAL_TYPE recommendedAction;
   double           confidenceScore;
   double           confluenceRating;
   bool             regimeApproved;
   bool             riskApproved;
   string           decisionReason;
};
