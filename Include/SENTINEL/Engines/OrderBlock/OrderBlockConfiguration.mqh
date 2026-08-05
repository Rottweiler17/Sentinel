//+------------------------------------------------------------------+
//|                                      OrderBlockConfiguration.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class COrderBlockConfiguration
/// @brief Configuration settings for order block detection sensitivities.
class COrderBlockConfiguration
{
private:
   double m_minStrength;
   int    m_retestLimit;

public:
   COrderBlockConfiguration()
      : m_minStrength(50.0),
        m_retestLimit(3)
   {}

   void SetMinStrength(double val) { m_minStrength = val; }
   void SetRetestLimit(int val)    { m_retestLimit = val; }

   double MinStrength() const { return m_minStrength; }
   int RetestLimit()    const { return m_retestLimit; }
};
