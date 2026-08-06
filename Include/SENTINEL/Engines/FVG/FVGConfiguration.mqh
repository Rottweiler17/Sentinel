//+------------------------------------------------------------------+
//|                                             FVGConfiguration.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CFVGConfiguration
/// @brief Configuration settings for Fair Value Gap detection sensitivities.
class CFVGConfiguration
{
private:
   double m_minGapSizePoints;
   double m_partialFillRatio;

public:
   CFVGConfiguration()
      : m_minGapSizePoints(10.0), // Min gap size in points
        m_partialFillRatio(50.0) // Percentage of gap filled to trigger partial state
   {}

   void SetMinGapSizePoints(double val) { m_minGapSizePoints = val; }
   void SetPartialFillRatio(double val) { m_partialFillRatio = val; }

   double MinGapSizePoints() const { return m_minGapSizePoints; }
   double PartialFillRatio() const { return m_partialFillRatio; }
};
