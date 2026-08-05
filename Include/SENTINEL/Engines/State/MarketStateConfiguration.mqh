//+------------------------------------------------------------------+
//|                                     MarketStateConfiguration.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CMarketStateConfiguration
/// @brief Configuration settings for market state environment analysis.
class CMarketStateConfiguration
{
private:
   double m_highVolatilityThreshold;
   double m_lowVolatilityThreshold;
   double m_trendStrengthThreshold;

public:
   CMarketStateConfiguration()
      : m_highVolatilityThreshold(1.5),
        m_lowVolatilityThreshold(0.5),
        m_trendStrengthThreshold(60.0)
   {}

   void SetHighVolatilityThreshold(double val) { m_highVolatilityThreshold = val; }
   void SetLowVolatilityThreshold(double val)  { m_lowVolatilityThreshold = val; }
   void SetTrendStrengthThreshold(double val)  { m_trendStrengthThreshold = val; }

   double HighVolatilityThreshold() const { return m_highVolatilityThreshold; }
   double LowVolatilityThreshold()  const { return m_lowVolatilityThreshold; }
   double TrendStrengthThreshold()  const { return m_trendStrengthThreshold; }
};
