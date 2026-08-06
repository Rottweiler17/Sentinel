//+------------------------------------------------------------------+
//|                                       ConfluenceStatistics.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @struct SConfluenceStatistics
/// @brief Runtime telemetry and performance metrics for Confluence Engine.
struct SConfluenceStatistics
{
   ulong  totalEvaluations;
   ulong  highAlignmentCount;
   ulong  highConflictCount;
   ulong  neutralCount;

   double sumConfluenceScore;
   double sumAlignmentScore;
   double sumConflictScore;

   void Reset()
   {
      totalEvaluations    = 0;
      highAlignmentCount  = 0;
      highConflictCount   = 0;
      neutralCount        = 0;
      sumConfluenceScore  = 0.0;
      sumAlignmentScore   = 0.0;
      sumConflictScore    = 0.0;
   }

   void RecordEvaluation(double confluenceScore, double alignmentScore, double conflictScore)
   {
      totalEvaluations++;
      sumConfluenceScore += confluenceScore;
      sumAlignmentScore  += alignmentScore;
      sumConflictScore   += conflictScore;

      if(alignmentScore >= 0.7)
         highAlignmentCount++;
      if(conflictScore >= 0.5)
         highConflictCount++;
      if(alignmentScore < 0.4 && conflictScore < 0.4)
         neutralCount++;
   }

   double GetAvgConfluenceScore() const
   {
      return (totalEvaluations > 0) ? (sumConfluenceScore / (double)totalEvaluations) : 0.0;
   }

   double GetAvgAlignmentScore() const
   {
      return (totalEvaluations > 0) ? (sumAlignmentScore / (double)totalEvaluations) : 0.0;
   }

   double GetAvgConflictScore() const
   {
      return (totalEvaluations > 0) ? (sumConflictScore / (double)totalEvaluations) : 0.0;
   }
};
