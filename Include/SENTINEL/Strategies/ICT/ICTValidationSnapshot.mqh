//+------------------------------------------------------------------+
//|                                     ICTValidationSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ICTValidationTypes.mqh"

/// @struct SICTValidationSnapshot
/// @brief Immutable snapshot capturing complete ICT setup validation evaluation state.
struct SICTValidationSnapshot
{
   ulong               snapshotId;
   ulong               sequenceNumber;
   datetime            timestamp;

   double              overallValidationScore;   ///< Overall setup validation score [0.0 to 1.0]
   double              confidence;               ///< Aggregated reliability confidence [0.0 to 1.0]
   
   int                 satisfiedCount;           ///< Count of satisfied ICT conditions
   int                 missingCount;             ///< Count of missing / unsatisfied ICT conditions
   bool                isSetupValid;             ///< True if setup meets minimum ICT validation threshold

   SICTConditionResult conditions[ICT_CONDITION_COUNT];

   void Reset()
   {
      snapshotId             = 0;
      sequenceNumber         = 0;
      timestamp              = 0;

      overallValidationScore = 0.0;
      confidence             = 0.0;
      satisfiedCount         = 0;
      missingCount           = 0;
      isSetupValid           = false;

      for(int i = 0; i < (int)ICT_CONDITION_COUNT; i++)
      {
         conditions[i].Reset();
         conditions[i].condition = (ENUM_ICT_CONDITION)i;
      }
   }
};
