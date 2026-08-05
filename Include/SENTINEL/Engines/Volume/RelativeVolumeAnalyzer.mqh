//+------------------------------------------------------------------+
//|                                       RelativeVolumeAnalyzer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CRelativeVolumeAnalyzer
/// @brief Computes Relative Volume (RVol) ratios comparing current candle volume against historic averages.
class CRelativeVolumeAnalyzer
{
public:
   static double CalculateRVol(double currentVolume, double averageVolume)
   {
      if(averageVolume <= 0.0) return 1.0;
      return currentVolume / averageVolume;
   }
};
