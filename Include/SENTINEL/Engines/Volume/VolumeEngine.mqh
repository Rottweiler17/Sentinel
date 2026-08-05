//+------------------------------------------------------------------+
//|                                                 VolumeEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/BaseEngine.mqh"
#include "../../Events/EventBus.mqh"
#include "IVolumeEngine.mqh"
#include "VolumeConfiguration.mqh"
#include "VolumeCache.mqh"
#include "VolumeCollector.mqh"
#include "TickVolumeAnalyzer.mqh"
#include "RelativeVolumeAnalyzer.mqh"
#include "VolumeStatistics.mqh"
#include "VolumeEvents.mqh"

/// @class CVolumeEngine
/// @brief Master Volume Engine. Collects tick and real volume feeds and tracks rolling average metrics and spike states.
class CVolumeEngine : public CBaseEngine, public IVolumeEngine, public IEventListener
{
private:
   CVolumeConfiguration m_config;
   CVolumeCache         m_cache;
   CVolumeCollector     m_collector;
   CVolumeStatistics    m_stats;
   SVolumeSnapshot      m_currentSnapshot;

   ulong                m_snapshotSequence;
   ulong                m_lastSnapshotId;

public:
   CVolumeEngine()
      : CBaseEngine("VolumeEngine"),
        m_stats(20),
        m_snapshotSequence(0),
        m_lastSnapshotId(0)
   {
      m_currentSnapshot.Reset();
   }

   /// @brief Initializes VolumeEngine.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      int avgPeriod = (int)config.GetInt("volume.rolling_average_period", 20);
      double spikeMultiplier = config.GetDouble("volume.spike_multiplier", 2.0);

      m_config.SetRollingAveragePeriod(avgPeriod);
      m_config.SetVolumeSpikeMultiplier(spikeMultiplier);

      if(m_eventBusRef != NULL)
      {
         m_eventBusRef.Subscribe(EVENT_MKT_TICK, this);
      }

      CLogger::Info(m_engineName, "VolumeEngine initialized.");
      return true;
   }

   /// @brief EventBus listener.
   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(!m_isEnabled) return;
   }

   /// @brief Processes volume calculations from MarketContext snapshots.
   virtual void ProcessVolume(const SMarketContext &context) override
   {
      if(!m_isEnabled || context.marketData.bid <= 0.0) return;

      // 1. Collect current volume details
      m_collector.Collect(context);
      double curVolume = m_collector.CurrentRealVolume();

      // 2. Update stats and rolling averages
      m_stats.Update(curVolume, context.marketData.time, (int)context.session.currentSession);
      double avgVol = m_stats.RollingAverage();

      // 3. Analyze volume states (spike, compression, etc.) and RVol
      ENUM_VOLUME_STATE volState = CTickVolumeAnalyzer::AnalyzeState(curVolume, avgVol, m_config);
      double rVol = CRelativeVolumeAnalyzer::CalculateRVol(curVolume, avgVol);

      ENUM_VOLUME_TREND volTrend = VOLUME_TREND_STABLE;
      if(curVolume > avgVol * 1.2) volTrend = VOLUME_TREND_INCREASING;
      else if(curVolume < avgVol * 0.8) volTrend = VOLUME_TREND_DECREASING;

      bool isSpikeTransition = (volState == VOLUME_STATE_SPIKE && m_currentSnapshot.volumeState != VOLUME_STATE_SPIKE);
      if(isSpikeTransition)
      {
         if(m_eventBusRef != NULL)
            m_eventBusRef.Publish(CVolumeEvents::CreateVolumeEvent(volState, curVolume, context.marketData.time));
      }

      // 4. Update Snapshot
      m_snapshotSequence++;
      ulong newSnapshotId = (ulong)context.marketData.currentTick.time_msc + m_snapshotSequence;

      m_currentSnapshot.snapshotId           = newSnapshotId;
      m_currentSnapshot.parentId             = m_lastSnapshotId;
      m_currentSnapshot.sequenceNumber       = m_snapshotSequence;
      m_currentSnapshot.currentTickVolume    = m_collector.CurrentTickVolume();
      m_currentSnapshot.currentRealVolume    = curVolume;
      m_currentSnapshot.rollingAverageVolume = avgVol;
      m_currentSnapshot.relativeVolume       = rVol;
      m_currentSnapshot.volumeTrend          = volTrend;
      m_currentSnapshot.volumeState          = volState;
      m_currentSnapshot.sessionVolume        = m_stats.SessionVolume();
      m_currentSnapshot.dailyVolume          = m_stats.DailyVolume();
      m_currentSnapshot.rateOfChange         = (avgVol > 0.0) ? ((curVolume - avgVol) / avgVol) * 100.0 : 0.0;
      m_currentSnapshot.timestamp            = context.timestamp;

      m_cache.AddSnapshot(m_currentSnapshot);
      m_lastSnapshotId = newSnapshotId;
   }

   virtual const SVolumeSnapshot* GetSnapshot() const override { return &m_currentSnapshot; }
};
