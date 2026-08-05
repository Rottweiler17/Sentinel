//+------------------------------------------------------------------+
//|                                       OrderFlowConfiguration.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class COrderFlowConfiguration
/// @brief Configuration settings for order flow approximation calculations.
class COrderFlowConfiguration
{
private:
   double m_aggressionThreshold;
   double m_absorptionThreshold;

public:
   COrderFlowConfiguration()
      : m_aggressionThreshold(1.5),
        m_absorptionThreshold(2.0)
   {}

   void SetAggressionThreshold(double val) { m_aggressionThreshold = val; }
   void SetAbsorptionThreshold(double val) { m_absorptionThreshold = val; }

   double AggressionThreshold() const { return m_aggressionThreshold; }
   double AbsorptionThreshold() const { return m_absorptionThreshold; }
};
