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
/// @brief Primary MT5 market data gateway. Generates SMarketDataSnapshot and dispatches EVENT_MKT_TICK via EventBus. Supports dependency injection.
class CDataEngine : public CBaseEngine
{
private:
   CTickEngine           *m_tickEngineRef;
   CSymbolManager        *m_symbolManagerRef;
   CTimeframeManager     *m_tfManagerRef;
   CHistoricalDataCache  *m_historyCacheRef;
   CTimeSynchronization  *m_timeSyncRef;

   bool                  m_ownTickEngine;
   bool                  m_ownSymbolManager;
   bool                  m_ownTfManager;
   bool                  m_ownHistoryCache;
   bool                  m_ownTimeSync;

   SMarketDataSnapshot   m_currentSnapshot;
   datetime              m_lastBarTime;

public:
   CDataEngine(CTickEngine *tickEngine = NULL, 
               CSymbolManager *symbolMgr = NULL, 
               CTimeframeManager *tfMgr = NULL, 
               CHistoricalDataCache *historyCache = NULL,
               CTimeSynchronization *timeSync = NULL)
      : CBaseEngine("DataEngine"),
        m_tickEngineRef(tickEngine),
        m_symbolManagerRef(symbolMgr),
        m_tfManagerRef(tfMgr),
        m_historyCacheRef(historyCache),
        m_timeSyncRef(timeSync),
        m_lastBarTime(0)
   {
      m_ownTickEngine   = (m_tickEngineRef == NULL);   if(m_ownTickEngine)   m_tickEngineRef   = new CTickEngine();
      m_ownSymbolManager= (m_symbolManagerRef == NULL); if(m_ownSymbolManager) m_symbolManagerRef= new CSymbolManager();
      m_ownTfManager    = (m_tfManagerRef == NULL);    if(m_ownTfManager)    m_tfManagerRef    = new CTimeframeManager();
      m_ownHistoryCache = (m_historyCacheRef == NULL); if(m_ownHistoryCache) m_historyCacheRef = new CHistoricalDataCache();
      m_ownTimeSync     = (m_timeSyncRef == NULL);     if(m_ownTimeSync)     m_timeSyncRef     = new CTimeSynchronization();
   }

   ~CDataEngine()
   {
      if(m_ownTickEngine)   SAFE_DELETE(m_tickEngineRef);
      if(m_ownSymbolManager) SAFE_DELETE(m_symbolManagerRef);
      if(m_ownTfManager)    SAFE_DELETE(m_tfManagerRef);
      if(m_ownHistoryCache) SAFE_DELETE(m_historyCacheRef);
      if(m_ownTimeSync)     SAFE_DELETE(m_timeSyncRef);
   }

   /// @brief Initializes DataEngine, symbol specifications, and pre-loads bar history.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      string symbol = config.GetString("symbol", _Symbol);
      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)config.GetInt("timeframe", _Period);

      m_symbolManagerRef.InitSymbol(symbol);
      m_tfManagerRef.SetTimeframe(tf);
      m_tickEngineRef.Initialize(config, bus);

      // Pre-load bar cache history
      CBarCache *primaryCache = m_historyCacheRef.GetCache(tf);
      CDataSynchronization::SyncHistory(symbol, tf, primaryCache, 500);

      CLogger::Info(m_engineName, StringFormat("DataEngine initialized for %s (%d min).", symbol, m_tfManagerRef.PeriodSecondsVal()/60));
      return true;
   }

   /// @brief Processes MT5 tick, updates snapshot, and publishes EVENT_MKT_TICK to EventBus.
   virtual void OnTick(const MqlTick &tick) override
   {
      if(!m_isEnabled) return;

      // 1. Process tick through TickEngine
      m_tickEngineRef.OnTick(tick);

      // 2. Update time synchronization
      m_timeSyncRef.Update();

      // 3. Build immutable SMarketDataSnapshot
      STickData latestTick;
      m_tickEngineRef.GetLatestTick(latestTick);

      CBarCache *barCache = m_historyCacheRef.GetCache(m_tfManagerRef.PrimaryTimeframe());

      m_currentSnapshot.Reset();
      m_currentSnapshot.currentTick       = latestTick;
      m_currentSnapshot.bid               = latestTick.bid;
      m_currentSnapshot.ask               = latestTick.ask;
      m_currentSnapshot.spread            = (int)MathRound((latestTick.ask - latestTick.bid) / m_symbolManagerRef.Point());
      m_currentSnapshot.time              = latestTick.time;
      m_currentSnapshot.serverTime        = m_timeSyncRef.ServerTime();
      m_currentSnapshot.localTime         = m_timeSyncRef.LocalTime();
      m_currentSnapshot.symbol            = m_symbolManagerRef.Symbol();
      m_currentSnapshot.digits            = m_symbolManagerRef.Digits();
      m_currentSnapshot.point             = m_symbolManagerRef.Point();
      m_currentSnapshot.tickSize          = m_symbolManagerRef.TickSize();
      m_currentSnapshot.tickValue         = m_symbolManagerRef.TickValue();
      m_currentSnapshot.timeframe         = m_tfManagerRef.PrimaryTimeframe();
      m_currentSnapshot.periodSeconds     = m_tfManagerRef.PeriodSecondsVal();
      m_currentSnapshot.isSymbolTradeable = m_symbolManagerRef.IsTradeable();
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
         event.symbol     = m_symbolManagerRef.Symbol();
         event.timeframe  = m_tfManagerRef.PrimaryTimeframe();
         event.priceValue = latestTick.bid;
         event.entityId   = (ulong)latestTick.time_msc;

         m_eventBusRef.Publish(event);

         // Check for new bar event
         if(CTimeUtils::IsNewBar(m_lastBarTime, latestTick.time, m_tfManagerRef.PrimaryTimeframe()))
         {
            m_lastBarTime = CTimeUtils::RoundToBarTime(latestTick.time, m_tfManagerRef.PrimaryTimeframe());
            CDataSynchronization::SyncHistory(m_symbolManagerRef.Symbol(), m_tfManagerRef.PrimaryTimeframe(), barCache, 10);

            SSentinelEvent barEvent;
            barEvent.type      = EVENT_MKT_NEW_BAR;
            barEvent.timestamp = m_lastBarTime;
            barEvent.symbol    = m_symbolManagerRef.Symbol();
            barEvent.timeframe = m_tfManagerRef.PrimaryTimeframe();
            barEvent.priceValue= latestTick.bid;

            m_eventBusRef.Publish(barEvent);
         }
      }
   }

   /// @brief Gets reference to the current immutable snapshot.
   const SMarketDataSnapshot* GetSnapshot() const { return &m_currentSnapshot; }

   CTickEngine* TickEngine() { return m_tickEngineRef; }

   virtual void Shutdown() override
   {
      m_tickEngineRef.Shutdown();
      CBaseEngine::Shutdown();
   }
};
