//+------------------------------------------------------------------+
//|                                                SessionEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/BaseEngine.mqh"
#include "../../Events/EventBus.mqh"
#include "ISessionEngine.mqh"
#include "SessionConfiguration.mqh"
#include "SessionCache.mqh"
#include "SessionDetector.mqh"
#include "SessionStatistics.mqh"
#include "SessionEvents.mqh"

/// @class CSessionEngine
/// @brief Master Session Engine. Tracks current trading sessions, statistics, and historical daily/weekly/monthly reference levels.
class CSessionEngine : public CBaseEngine, public ISessionEngine, public IEventListener
{
private:
   CSessionConfiguration   m_config;
   CSessionCache           m_cache;
   CSessionStatistics      m_stats;
   SSessionSnapshot        m_currentSnapshot;

   // Dynamic Reference Level tracking (extracted purely from context feed)
   datetime                m_lastDayTime;
   datetime                m_lastWeekTime;
   datetime                m_lastMonthTime;

   double                  m_todayHigh;
   double                  m_todayLow;
   double                  m_weekHigh;
   double                  m_weekLow;
   double                  m_monthHigh;
   double                  m_monthLow;

   ulong                   m_snapshotSequence;
   ulong                   m_lastSnapshotId;

public:
   CSessionEngine()
      : CBaseEngine("SessionEngine"),
        m_lastDayTime(0), m_lastWeekTime(0), m_lastMonthTime(0),
        m_todayHigh(0.0), m_todayLow(999999.0),
        m_weekHigh(0.0),  m_weekLow(999999.0),
        m_monthHigh(0.0), m_monthLow(999999.0),
        m_snapshotSequence(0),
        m_lastSnapshotId(0)
   {
      m_currentSnapshot.Reset();
   }

   /// @brief Initializes SessionEngine.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      int brokerOffset = (int)config.GetInt("session.broker_offset_hours", 2);
      m_config.SetBrokerOffsetHours(brokerOffset);

      if(m_eventBusRef != NULL)
      {
         m_eventBusRef.Subscribe(EVENT_MKT_TICK, this);
      }

      CLogger::Info(m_engineName, "SessionEngine initialized.");
      return true;
   }

   /// @brief EventBus subscriber handler.
   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(!m_isEnabled) return;
   }

   /// @brief Core session and reference level updating process.
   virtual void ProcessSession(const SMarketContext &context) override
   {
      if(!m_isEnabled || context.marketData.bid <= 0.0) return;

      datetime curTime = context.marketData.time;
      double curPrice = context.marketData.bid;

      // 1. Detect current session hour transitions
      ENUM_MARKET_SESSION newSession = CSessionDetector::DetectSession(curTime, m_config);
      if(newSession != m_currentSnapshot.currentSession)
      {
         m_stats.RecordSessionEnd();
         m_stats.Reset();

         if(m_eventBusRef != NULL)
            m_eventBusRef.Publish(CSessionEvents::CreateSessionEvent(newSession, curTime));
      }

      m_stats.Update(curPrice, curTime);

      // 2. Track reference level daily/weekly/monthly transitions purely from feed data
      MqlDateTime dt;
      TimeToStruct(curTime, dt);

      // Daily transition
      datetime dayStart = curTime - (dt.hour * 3600 + dt.min * 60 + dt.sec);
      if(dayStart != m_lastDayTime)
      {
         m_currentSnapshot.referenceLevels.prevDayHigh  = m_todayHigh;
         m_currentSnapshot.referenceLevels.prevDayLow   = m_todayLow;
         m_currentSnapshot.referenceLevels.currentDayOpen = curPrice;
         m_todayHigh = curPrice;
         m_todayLow  = curPrice;
         m_lastDayTime = dayStart;
      }
      else
      {
         m_todayHigh = MathMax(m_todayHigh, curPrice);
         m_todayLow  = MathMin(m_todayLow, curPrice);
      }

      // Weekly transition (day of week: 0 is Sunday, 1 Monday, etc.)
      int daysSinceMonday = (dt.day_of_week == 0) ? 6 : (dt.day_of_week - 1);
      datetime weekStart = dayStart - (daysSinceMonday * 86400);
      if(weekStart != m_lastWeekTime)
      {
         m_currentSnapshot.referenceLevels.prevWeekHigh  = m_weekHigh;
         m_currentSnapshot.referenceLevels.prevWeekLow   = m_weekLow;
         m_currentSnapshot.referenceLevels.currentWeekOpen = curPrice;
         m_weekHigh = curPrice;
         m_weekLow  = curPrice;
         m_lastWeekTime = weekStart;
      }
      else
      {
         m_weekHigh = MathMax(m_weekHigh, curPrice);
         m_weekLow  = MathMin(m_weekLow, curPrice);
      }

      // Monthly transition
      datetime monthStart = dayStart - ((dt.day - 1) * 86400);
      if(monthStart != m_lastMonthTime)
      {
         m_currentSnapshot.referenceLevels.prevMonthHigh  = m_monthHigh;
         m_currentSnapshot.referenceLevels.prevMonthLow   = m_monthLow;
         m_currentSnapshot.referenceLevels.currentMonthOpen = curPrice;
         m_monthHigh = curPrice;
         m_monthLow  = curPrice;
         m_lastMonthTime = monthStart;
      }
      else
      {
         m_monthHigh = MathMax(m_monthHigh, curPrice);
         m_monthLow  = MathMin(m_monthLow, curPrice);
      }

      // 3. Emit Snapshot
      UpdateSnapshot(context, newSession);
   }

   virtual const SSessionSnapshot* GetSnapshot() const override { return &m_currentSnapshot; }

private:
   /// @brief Updates current immutable SSessionSnapshot with version tracking.
   void UpdateSnapshot(const SMarketContext &context, ENUM_MARKET_SESSION session)
   {
      m_snapshotSequence++;
      ulong newSnapshotId = (ulong)context.marketData.currentTick.time_msc + m_snapshotSequence;

      m_currentSnapshot.snapshotId     = newSnapshotId;
      m_currentSnapshot.parentId       = m_lastSnapshotId;
      m_currentSnapshot.sequenceNumber = m_snapshotSequence;
      m_currentSnapshot.currentSession = session;
      m_currentSnapshot.stats          = *m_stats.GetStats();
      m_currentSnapshot.timestamp      = context.timestamp;

      m_cache.AddSnapshot(m_currentSnapshot);
      m_lastSnapshotId = newSnapshotId;
   }
};
