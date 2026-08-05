//+------------------------------------------------------------------+
//|                                           MarketDataSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Common/Types.mqh"
#include "../Common/Constants.mqh"

/// @struct SMarketDataSnapshot
/// @brief Immutable complete market state snapshot generated once per OnTick() with version tracking.
struct SMarketDataSnapshot
{
   // Snapshot Versioning & Lineage Metadata
   ulong             snapshotId;       ///< Unique identifier for this snapshot
   ulong             parentId;         ///< Identifier of previous snapshot
   ulong             sequenceNumber;   ///< Monotonically increasing tick sequence number

   // Tick & Price Details
   STickData         currentTick;
   double            bid;
   double            ask;
   int               spread;

   // Candle Information
   SBarData          currentCandle;
   SBarData          previousCandle;

   // Time Metrics
   datetime          time;
   datetime          serverTime;
   datetime          localTime;

   // Symbol Properties
   string            symbol;
   int               digits;
   double            point;
   double            tickSize;
   double            tickValue;

   // Session & Environment State
   SSessionData      sessionInfo;
   ENUM_TIMEFRAMES   timeframe;
   long              periodSeconds;
   bool              isSymbolTradeable;

   /// @brief Resets all snapshot fields to clean zero state.
   void Reset()
   {
      snapshotId        = 0;
      parentId          = 0;
      sequenceNumber    = 0;
      bid               = 0.0;
      ask               = 0.0;
      spread            = 0;
      time              = 0;
      serverTime        = 0;
      localTime         = 0;
      symbol            = "";
      digits            = 0;
      point             = 0.0;
      tickSize          = 0.0;
      tickValue         = 0.0;
      timeframe         = PERIOD_CURRENT;
      periodSeconds     = 0;
      isSymbolTradeable = false;
   }
};
