//+------------------------------------------------------------------+
//|                                          VolumeConfiguration.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CVolumeConfiguration
/// @brief Configuration settings for generic volume analysis and spike detection.
class CVolumeConfiguration
{
private:
   int    m_rollingAveragePeriod;
   double m_volumeSpikeMultiplier;

public:
   CVolumeConfiguration()
      : m_rollingAveragePeriod(20),
        m_volumeSpikeMultiplier(2.0)
   {}

   void SetRollingAveragePeriod(int val)     { m_rollingAveragePeriod = val > 0 ? val : 20; }
   void SetVolumeSpikeMultiplier(double val) { m_volumeSpikeMultiplier = val > 0.0 ? val : 2.0; }

   int RollingAveragePeriod()     const { return m_rollingAveragePeriod; }
   double VolumeSpikeMultiplier() const { return m_volumeSpikeMultiplier; }
};
