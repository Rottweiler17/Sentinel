//+------------------------------------------------------------------+
//|                                         SessionConfiguration.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CSessionConfiguration
/// @brief Configuration container for session time windows and broker GMT timezone offsets.
class CSessionConfiguration
{
private:
   int m_brokerOffsetHours;

   // Session hours (GMT base, converted to broker time internally)
   int m_asianStartHour;
   int m_asianEndHour;
   int m_londonStartHour;
   int m_londonEndHour;
   int m_newyorkStartHour;
   int m_newyorkEndHour;
   int m_sydneyStartHour;
   int m_sydneyEndHour;

public:
   CSessionConfiguration()
      : m_brokerOffsetHours(2), // Default broker timezone offset (e.g. GMT+2 or GMT+3 for DST)
        m_asianStartHour(0), m_asianEndHour(8),
        m_londonStartHour(8), m_londonEndHour(16),
        m_newyorkStartHour(13), m_newyorkEndHour(21),
        m_sydneyStartHour(22), m_sydneyEndHour(6)
   {}

   // Time offsets
   void SetBrokerOffsetHours(int val) { m_brokerOffsetHours = val; }
   int BrokerOffsetHours() const { return m_brokerOffsetHours; }

   // Session window hours getters/setters
   void SetAsianWindow(int start, int end)    { m_asianStartHour = start; m_asianEndHour = end; }
   void SetLondonWindow(int start, int end)   { m_londonStartHour = start; m_londonEndHour = end; }
   void SetNewYorkWindow(int start, int end)  { m_newyorkStartHour = start; m_newyorkEndHour = end; }
   void SetSydneyWindow(int start, int end)   { m_sydneyStartHour = start; m_sydneyEndHour = end; }

   int AsianStart()  const { return (m_asianStartHour + m_brokerOffsetHours) % 24; }
   int AsianEnd()    const { return (m_asianEndHour + m_brokerOffsetHours) % 24; }
   int LondonStart() const { return (m_londonStartHour + m_brokerOffsetHours) % 24; }
   int LondonEnd()   const { return (m_londonEndHour + m_brokerOffsetHours) % 24; }
   int NewYorkStart()const { return (m_newyorkStartHour + m_brokerOffsetHours) % 24; }
   int NewYorkEnd()  const { return (m_newyorkEndHour + m_brokerOffsetHours) % 24; }
   int SydneyStart() const { return (m_sydneyStartHour + m_brokerOffsetHours) % 24; }
   int SydneyEnd()   const { return (m_sydneyEndHour + m_brokerOffsetHours) % 24; }
};
