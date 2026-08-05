//+------------------------------------------------------------------+
//|                                                   TickEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Core/BaseEngine.mqh"
#include "TickValidation.mqh"
#include "LiveTickCache.mqh"

/// @class CTickEngine
/// @brief Captures, validates, and caches raw MT5 tick stream. Tracks telemetry metrics (ticks/sec, dropped ticks, validation failures).
class CTickEngine : public CBaseEngine
{
private:
   CLiveTickCache m_tickCache;
   STickData      m_latestTick;
   datetime       m_lastTickTime;

   // Performance & Diagnostic Telemetry Metrics
   long           m_totalTicksProcessed;
   long           m_droppedTicksCount;
   long           m_validationFailuresCount;
   datetime       m_lastMetricResetTime;
   int            m_ticksInCurrentSecond;
   double         m_ticksPerSecond;

public:
   CTickEngine()
      : CBaseEngine("TickEngine"),
        m_tickCache(SENTINEL_DEFAULT_TICK_CAPACITY),
        m_lastTickTime(0),
        m_totalTicksProcessed(0),
        m_droppedTicksCount(0),
        m_validationFailuresCount(0),
        m_lastMetricResetTime(0),
        m_ticksInCurrentSecond(0),
        m_ticksPerSecond(0.0)
   {}

   /// @brief Processes real-time MT5 tick with validation and metric tracking.
   virtual void OnTick(const MqlTick &tick) override
   {
      if(!m_isEnabled) return;

      m_totalTicksProcessed++;

      // Telemetry ticks/sec tracking
      datetime now = TimeCurrent();
      if(now != m_lastMetricResetTime)
      {
         m_ticksPerSecond = (double)m_ticksInCurrentSecond;
         m_ticksInCurrentSecond = 1;
         m_lastMetricResetTime = now;
      }
      else
      {
         m_ticksInCurrentSecond++;
      }

      // Tick Validation Check
      if(!CTickValidation::IsValidTick(tick, m_lastTickTime))
      {
         m_validationFailuresCount++;
         m_droppedTicksCount++;
         return;
      }

      m_latestTick.time        = tick.time;
      m_latestTick.bid         = tick.bid;
      m_latestTick.ask         = tick.ask;
      m_latestTick.last        = tick.last;
      m_latestTick.volume      = tick.volume;
      m_latestTick.time_msc    = tick.time_msc;
      m_latestTick.flags       = tick.flags;
      m_latestTick.volume_real = tick.volume_real;

      if(!m_tickCache.AddTick(m_latestTick))
      {
         m_droppedTicksCount++;
      }

      m_lastTickTime = tick.time;
   }

   bool GetLatestTick(STickData &outTick) const
   {
      outTick = m_latestTick;
      return (m_latestTick.bid > 0.0);
   }

   // --- Telemetry Getters ---
   long TotalTicksProcessed()     const { return m_totalTicksProcessed; }
   long DroppedTicks()            const { return m_droppedTicksCount; }
   long ValidationFailures()      const { return m_validationFailuresCount; }
   double TicksPerSecond()        const { return m_ticksPerSecond; }

   CLiveTickCache* Cache() { return &m_tickCache; }
};
