//+------------------------------------------------------------------+
//|                                             TimeframeManager.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CTimeframeManager
/// @brief Manages monitored chart timeframes and period calculations.
class CTimeframeManager
{
private:
   ENUM_TIMEFRAMES m_primaryTf;
   long            m_periodSeconds;

public:
   CTimeframeManager(ENUM_TIMEFRAMES tf = PERIOD_CURRENT)
   {
      SetTimeframe(tf);
   }

   void SetTimeframe(ENUM_TIMEFRAMES tf)
   {
      m_primaryTf     = (tf == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)_Period : tf;
      m_periodSeconds = PeriodSeconds(m_primaryTf);
   }

   ENUM_TIMEFRAMES PrimaryTimeframe() const { return m_primaryTf; }
   long PeriodSecondsVal() const { return m_periodSeconds; }
};
