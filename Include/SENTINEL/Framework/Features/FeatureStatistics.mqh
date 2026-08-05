//+------------------------------------------------------------------+
//|                                           FeatureStatistics.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CFeatureStatistics
/// @brief Tracks diagnostic counters for feature extraction cycles.
class CFeatureStatistics
{
private:
   int m_extractedVectorsCount;
   int m_confidenceDropTriggers;

public:
   CFeatureStatistics() : m_extractedVectorsCount(0), m_confidenceDropTriggers(0) {}

   void RecordExtraction()          { m_extractedVectorsCount++; }
   void RecordConfidenceDrop()      { m_confidenceDropTriggers++; }

   int ExtractedVectorsCount() const { return m_extractedVectorsCount; }
   int ConfidenceDropTriggers() const { return m_confidenceDropTriggers; }

   void Reset()
   {
      m_extractedVectorsCount  = 0;
      m_confidenceDropTriggers = 0;
   }
};
