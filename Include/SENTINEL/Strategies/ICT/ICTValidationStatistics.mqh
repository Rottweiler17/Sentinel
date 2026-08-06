//+------------------------------------------------------------------+
//|                                     ICTValidationStatistics.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @struct SICTValidationStatistics
/// @brief Runtime telemetry and performance metrics for ICT Validation Module.
struct SICTValidationStatistics
{
   ulong  totalEvaluations;
   ulong  validSetupCount;
   double sumValidationScore;

   void Reset()
   {
      totalEvaluations   = 0;
      validSetupCount    = 0;
      sumValidationScore = 0.0;
   }

   void RecordEvaluation(double score, bool isValid)
   {
      totalEvaluations++;
      sumValidationScore += score;
      if(isValid)
         validSetupCount++;
   }

   double GetAvgScore() const
   {
      return (totalEvaluations > 0) ? (sumValidationScore / (double)totalEvaluations) : 0.0;
   }
};
