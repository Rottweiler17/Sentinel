//+------------------------------------------------------------------+
//|                                                   TickEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Core/BaseEngine.mqh"
#include "TickValidation.mqh"
#include "LiveTickCache.mqh"

/// @class CTickEngine
/// @brief Captures, validates, and caches raw MT5 tick stream in high-speed ring buffer.
class CTickEngine : public CBaseEngine
{
private:
   CLiveTickCache m_tickCache;
   STickData      m_latestTick;
   datetime       m_lastTickTime;

public:
   CTickEngine()
      : CBaseEngine("TickEngine"), m_tickCache(SENTINEL_DEFAULT_TICK_CAPACITY), m_lastTickTime(0)
   {}

   /// @brief Processes real-time MT5 tick.
   virtual void OnTick(const MqlTick &tick) override
   {
      if(!m_isEnabled) return;

      if(!CTickValidation::IsValidTick(tick, m_lastTickTime))
         return;

      m_latestTick.time        = tick.time;
      m_latestTick.bid         = tick.bid;
      m_latestTick.ask         = tick.ask;
      m_latestTick.last        = tick.last;
      m_latestTick.volume      = tick.volume;
      m_latestTick.time_msc    = tick.time_msc;
      m_latestTick.flags       = tick.flags;
      m_latestTick.volume_real = tick.volume_real;

      m_tickCache.AddTick(m_latestTick);
      m_lastTickTime = tick.time;
   }

   bool GetLatestTick(STickData &outTick) const
   {
      outTick = m_latestTick;
      return (m_latestTick.bid > 0.0);
   }

   CLiveTickCache* Cache() { return &m_tickCache; }
};
