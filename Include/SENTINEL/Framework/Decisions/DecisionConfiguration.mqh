//+------------------------------------------------------------------+
//|                                        DecisionConfiguration.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CDecisionConfiguration
/// @brief Configuration thresholds for confluence evaluations.
class CDecisionConfiguration
{
private:
   double m_confluenceThreshold;
   double m_minScoreThreshold;

public:
   CDecisionConfiguration()
      : m_confluenceThreshold(60.0),
        m_minScoreThreshold(50.0)
   {}

   void SetConfluenceThreshold(double val) { m_confluenceThreshold = val; }
   void SetMinScoreThreshold(double val)   { m_minScoreThreshold = val; }

   double ConfluenceThreshold() const { return m_confluenceThreshold; }
   double MinScoreThreshold()   const { return m_minScoreThreshold; }
};
