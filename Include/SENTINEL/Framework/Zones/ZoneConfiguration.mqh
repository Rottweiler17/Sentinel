//+------------------------------------------------------------------+
//|                                            ZoneConfiguration.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CZoneConfiguration
/// @brief Configurable threshold container for generic zone validation, expiry, and merging.
class CZoneConfiguration
{
private:
   double m_minHeightPips;
   double m_maxHeightPips;
   long   m_minAgeSeconds;
   long   m_maxAgeSeconds;
   int    m_minTouchesRequired;
   double m_overlapPercentThreshold;
   int    m_maxActiveZones;

public:
   CZoneConfiguration()
      : m_minHeightPips(2.0),
        m_maxHeightPips(200.0),
        m_minAgeSeconds(60),
        m_maxAgeSeconds(864000), // 10 days
        m_minTouchesRequired(1),
        m_overlapPercentThreshold(50.0),
        m_maxActiveZones(100)
   {}

   // Setters
   void SetMinHeightPips(double val)       { m_minHeightPips = val > 0.0 ? val : 2.0; }
   void SetMaxHeightPips(double val)       { m_maxHeightPips = val > 0.0 ? val : 200.0; }
   void SetMinAgeSeconds(long val)         { m_minAgeSeconds = val >= 0 ? val : 0; }
   void SetMaxAgeSeconds(long val)         { m_maxAgeSeconds = val > 0 ? val : 864000; }
   void SetMinTouchesRequired(int val)     { m_minTouchesRequired = val > 0 ? val : 1; }
   void SetOverlapPercentThreshold(double val){ m_overlapPercentThreshold = (val >= 0.0 && val <= 100.0) ? val : 50.0; }
   void SetMaxActiveZones(int val)         { m_maxActiveZones = val > 0 ? val : 100; }

   // Getters
   double MinHeightPips()           const { return m_minHeightPips; }
   double MaxHeightPips()           const { return m_maxHeightPips; }
   long   MinAgeSeconds()           const { return m_minAgeSeconds; }
   long   MaxAgeSeconds()           const { return m_maxAgeSeconds; }
   int    MinTouchesRequired()     const { return m_minTouchesRequired; }
   double OverlapPercentThreshold() const { return m_overlapPercentThreshold; }
   int    MaxActiveZones()         const { return m_maxActiveZones; }
};
