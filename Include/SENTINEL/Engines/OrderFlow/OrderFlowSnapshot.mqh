//+------------------------------------------------------------------+
//|                                                OrderFlowSnapshot.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "OrderFlowTypes.mqh"

/// @struct SOrderFlowSnapshot
/// @brief Immutable snapshot of generic order flow approximation values.
/// @note All values are framework-derived estimates based on available MT5 tick/context feeds.
struct SOrderFlowSnapshot
{
   // Snapshot Versioning & Lineage Metadata
   ulong                snapshotId;
   ulong                parentId;
   ulong                sequenceNumber;

   // Derived Pressures
   double               buyingPressure;      ///< 0.0 to 100.0%
   double               sellingPressure;     ///< 0.0 to 100.0%
   double               pressureBalance;     ///< Ratio (e.g. 0.5 represents balanced, > 0.5 bullish)
   
   // Participation & Initiative
   double               participationScore;  ///< 0.0 to 100.0%
   ENUM_INITIATIVE_TYPE initiative;
   
   // Estimators
   ENUM_ABSORPTION_STATE absorptionEstimate;
   double               aggressionEstimate;  ///< Estimated aggression percentage
   bool                 volumeConfirmation;
   double               confidence;
   datetime             timestamp;

   /// @brief Resets the snapshot data.
   void Reset()
   {
      snapshotId         = 0;
      parentId           = 0;
      sequenceNumber     = 0;
      buyingPressure     = 0.0;
      sellingPressure    = 0.0;
      pressureBalance    = 0.5;
      participationScore = 0.0;
      initiative         = INITIATIVE_NONE;
      absorptionEstimate = ABSORPTION_NONE;
      aggressionEstimate = 0.0;
      volumeConfirmation = false;
      confidence         = 0.0;
      timestamp          = 0;
   }
};
