//+------------------------------------------------------------------+
//|                                                   DataEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Core/BaseEngine.mqh"
#include "../Events/EventBus.mqh"
#include "MarketDataSnapshot.mqh"
#include "TickEngine.mqh"
#include "SymbolManager.mqh"
#include "TimeframeManager.mqh"
#include "HistoricalDataCache.mqh"
#include "DataSynchronization.mqh"
#include "TimeSynchronization.mqh"
#include "../Utilities/TimeUtils.mqh"

/// @class CDataEngine
/// @brief Primary MT5 market data gateway. Generates SMarketDataSnapshot and dispatches EVENT_MKT_TICK via EventBus.
class CDataEngine : public CBaseEngine
{
private:
   CTickEngine           m_tickEngine;
   CSymbolManager        m_symbolManager;
   CTimeframeManager     m_tfManager;
   CHistoricalDataCache  m_historyCache;
   CTimeSynchronization  m_timeSync;
   SMarketDataSnapshot   m_currentSnapshot;
   datetime              m_lastBarTime;

public:
   CDataEngine()
      : CBaseEngine("DataEngine"), m_lastBarTime(0)
   {}

   /// @brief Initializes DataEngine, symbol specifications, and pre-loads bar history.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      string symbol = config.GetString("symbol", _Symbol);
      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)config.GetInt("timeframe", _Period);

      m_symbolManager.InitSymbol(symbol);
      m_tfManager.SetTimeframe(tf);
      m_tickEngine.Initialize(config, bus);

      // Pre-load bar cache history
      CBarCache *primaryCache = m_historyCache.GetCache(tf);
      CDataSynchronization::SyncHistory(symbol, tf, primaryCache, 500);

      CLogger::Info(m_engineName, StringFormat("DataEngine initialized for %s (%d min).", symbol, m_tfManager.PeriodSecondsVal()/60));
      return true;
   }

   /// @brief Processes MT5 tick, updates snapshot, and publishes EVENT_MKT_TICK to EventBus.
   virtual void OnTick(const MqlTick &tick) override
   {
      if(!m_isEnabled) return;

      // 1. Process tick through TickEngine
      m_tickEngine.OnTick(tick);

      // 2. Update time synchronization
      m_timeSync.Update();

      // 3. Build immutable SMarketDataSnapshot
      STickData latestTick;
      m_tickEngine.GetLatestTick(latestTick);

      CBarCache *barCache = m_historyCache.GetCache(m_tfManager.PrimaryTimeframe());

      m_currentSnapshot.Reset();
      m_currentSnapshot.currentTick       = latestTick;
      m_currentSnapshot.bid               = latestTick.bid;
      m_currentSnapshot.ask               = latestTick.ask;
      m_currentSnapshot.spread            = (int)MathRound((latestTick.ask - latestTick.bid) / m_symbolManager.Point());
      m_currentSnapshot.time              = latestTick.time;
      m_currentSnapshot.serverTime        = m_timeSync.ServerTime();
      m_currentSnapshot.localTime         = m_timeSync.LocalTime();
      m_currentSnapshot.symbol            = m_symbolManager.Symbol();
      m_currentSnapshot.digits            = m_symbolManager.Digits();
      m_currentSnapshot.point             = m_symbolManager.Point();
      m_currentSnapshot.tickSize          = m_symbolManager.TickSize();
      m_currentSnapshot.tickValue         = m_symbolManager.TickValue();
      m_currentSnapshot.timeframe         = m_tfManager.PrimaryTimeframe();
      m_currentSnapshot.periodSeconds     = m_tfManager.PeriodSecondsVal();
      m_currentSnapshot.isSymbolTradeable = m_symbolManager.IsTradeable();
      m_currentSnapshot.sessionInfo.currentSession = CTimeUtils::GetCurrentSession(latestTick.time);

      if(barCache != NULL && barCache.Size() > 0)
      {
         barCache.GetCurrentBar(m_currentSnapshot.currentCandle);
         barCache.GetPreviousBar(m_currentSnapshot.previousCandle);
      }

      // 4. Publish EVENT_MKT_TICK event to EventBus
      if(m_eventBusRef != NULL)
      {
         SSentinelEvent event;
         event.type       = EVENT_MKT_TICK;
         event.timestamp  = latestTick.time;
         event.symbol     = m_symbolManager.Symbol();
         event.timeframe  = m_tfManager.PrimaryTimeframe();
         event.priceValue = latestTick.bid;
         event.entityId   = (ulong)latestTick.time_msc;

         m_eventBusRef.Publish(event);

         // Check for new bar event
         if(CTimeUtils::IsNewBar(m_lastBarTime, latestTick.time, m_tfManager.PrimaryTimeframe()))
         {
            m_lastBarTime = CTimeUtils::RoundToBarTime(latestTick.time, m_tfManager.PrimaryTimeframe());
            CDataSynchronization::SyncHistory(m_symbolManager.Symbol(), m_tfManager.PrimaryTimeframe(), barCache, 10);

            SSentinelEvent barEvent;
            barEvent.type      = EVENT_MKT_NEW_BAR;
            barEvent.timestamp = m_lastBarTime;
            barEvent.symbol    = m_symbolManager.Symbol();
            barEvent.timeframe = m_tfManager.PrimaryTimeframe();
            barEvent.priceValue= latestTick.bid;

            m_eventBusRef.Publish(barEvent);
         }
      }
   }

   /// @brief Gets reference to the current immutable snapshot.
   const SMarketDataSnapshot* GetSnapshot() const { return &m_currentSnapshot; }

   virtual void Shutdown() override
   {
      m_tickEngine.Shutdown();
      CBaseEngine::Shutdown();
   }
};
