//+------------------------------------------------------------------+
//|                                            ContextStatistics.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CContextStatistics
/// @brief Tracks context framework diagnostic counters.
class CContextStatistics
{
private:
   int m_createdContexts;
   int m_validationFailures;

public:
   CContextStatistics() : m_createdContexts(0), m_validationFailures(0) {}

   void RecordCreated()           { m_createdContexts++; }
   void RecordValidationFailure() { m_validationFailures++; }

   int CreatedContexts()    const { return m_createdContexts; }
   int ValidationFailures() const { return m_validationFailures; }

   void Reset()
   {
      m_createdContexts    = 0;
      m_validationFailures = 0;
   }
};
