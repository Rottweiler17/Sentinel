//+------------------------------------------------------------------+
//|                                         FeatureConfiguration.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CFeatureConfiguration
/// @brief Configuration settings for features normalization ranges.
class CFeatureConfiguration
{
private:
   double m_minNormalized;
   double m_maxNormalized;

public:
   CFeatureConfiguration()
      : m_minNormalized(-1.0),
        m_maxNormalized(1.0)
   {}

   void SetNormalizedRange(double minVal, double maxVal)
   {
      m_minNormalized = minVal;
      m_maxNormalized = maxVal;
   }

   double MinNormalized() const { return m_minNormalized; }
   double MaxNormalized() const { return m_maxNormalized; }
};
