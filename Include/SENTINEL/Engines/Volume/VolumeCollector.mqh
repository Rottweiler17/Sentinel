//+------------------------------------------------------------------+
//|                                              VolumeCollector.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"

/// @class CVolumeCollector
/// @brief Collects and caches volume values from market snapshots inside the context feed.
class CVolumeCollector
{
private:
   long   m_currentTickVolume;
   double m_currentRealVolume;

public:
   CVolumeCollector() : m_currentTickVolume(0), m_currentRealVolume(0.0) {}

   void Collect(const SMarketContext &context)
   {
      m_currentTickVolume = context.marketData.currentTick.volume;
      m_currentRealVolume = context.marketData.currentTick.volume_real;
      if(m_currentRealVolume <= 0.0)
         m_currentRealVolume = (double)m_currentTickVolume;
   }

   long CurrentTickVolume() const { return m_currentTickVolume; }
   double CurrentRealVolume() const { return m_currentRealVolume; }
};
