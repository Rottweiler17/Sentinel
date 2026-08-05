//+------------------------------------------------------------------+
//|                                           TickVolumeAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "VolumeTypes.mqh"
#include "VolumeConfiguration.mqh"

/// @class CTickVolumeAnalyzer
/// @brief Analyzes tick volume spikes and volume dry-up states against historical averages.
class CTickVolumeAnalyzer
{
public:
   static ENUM_VOLUME_STATE AnalyzeState(double currentVolume, double avgVolume, const CVolumeConfiguration &config)
   {
      if(avgVolume <= 0.0) return VOLUME_STATE_NORMAL;

      double ratio = currentVolume / avgVolume;
      if(ratio >= config.VolumeSpikeMultiplier())
         return VOLUME_STATE_SPIKE;

      if(ratio <= 0.3)
         return VOLUME_STATE_DRYUP;

      if(ratio >= 1.3)
         return VOLUME_STATE_EXPANSION;

      if(ratio <= 0.7)
         return VOLUME_STATE_COMPRESSION;

      return VOLUME_STATE_NORMAL;
   }
};
