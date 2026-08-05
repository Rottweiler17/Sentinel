//+------------------------------------------------------------------+
//|                                                 FeatureTypes.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @struct SStandardFeature
/// @brief Standardized feature metric wrapper.
struct SStandardFeature
{
   double   rawValue;
   double   normalizedValue; ///< Normalized range (typically 0.0 to 1.0 or -1.0 to 1.0)
   double   confidence;      ///< 0.0 to 100.0%
   datetime timestamp;
   int      sourceEngineId;  ///< Identifier for source analysis engine
};
