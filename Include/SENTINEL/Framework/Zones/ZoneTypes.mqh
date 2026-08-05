//+------------------------------------------------------------------+
//|                                                    ZoneTypes.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Types.mqh"

/// @enum ENUM_ZONE_CATEGORY
/// @brief Generic classification of price zones. Completely strategy-agnostic.
enum ENUM_ZONE_CATEGORY
{
   ZONE_CATEGORY_UNKNOWN = 0,
   ZONE_CATEGORY_SUPPORT,
   ZONE_CATEGORY_RESISTANCE,
   ZONE_CATEGORY_SUPPLY,
   ZONE_CATEGORY_DEMAND,
   ZONE_CATEGORY_NEUTRAL,
   ZONE_CATEGORY_CUSTOM
};

/// @enum ENUM_ZONE_LIFECYCLE
/// @brief Explicit lifecycle state transitions for a generic price zone object.
enum ENUM_ZONE_LIFECYCLE
{
   ZONE_LIFECYCLE_CREATED = 0,   ///< Newly constructed zone
   ZONE_LIFECYCLE_VALIDATED,     ///< Passed height/age validation rules
   ZONE_LIFECYCLE_ACTIVE,        ///< Active resting zone watching price action
   ZONE_LIFECYCLE_RETESTED,      ///< Retested / touched by price
   ZONE_LIFECYCLE_MERGED,        ///< Merged into an overlapping zone
   ZONE_LIFECYCLE_MITIGATED,     ///< Partially penetrated / mitigated
   ZONE_LIFECYCLE_CONSUMED,      ///< Fully broken / invalidated
   ZONE_LIFECYCLE_EXPIRED        ///< Expired by time or bar count limit
};

/// @enum ENUM_ZONE_PRIORITY
/// @brief Priority rating for zone significance.
enum ENUM_ZONE_PRIORITY
{
   ZONE_PRIORITY_LOW = 0,
   ZONE_PRIORITY_NORMAL,
   ZONE_PRIORITY_HIGH,
   ZONE_PRIORITY_CRITICAL
};

/// @struct SGenericZone
/// @brief Completely generic price zone data structure. Base model for all future zone modules.
struct SGenericZone
{
   ulong                id;
   ENUM_ZONE_CATEGORY   category;
   ENUM_ZONE_LIFECYCLE  lifecycleState;
   ENUM_ZONE_PRIORITY   priority;
   ENUM_TIMEFRAMES      timeframe;

   // Price Boundaries
   double               upperPrice;
   double               lowerPrice;
   double               midPrice;

   // Creation Details
   datetime             creationTime;
   SBarData             creationCandle;

   // Performance & Quality Metrics
   double               strength;          ///< Score 0.0 to 100.0
   double               confidence;        ///< Confidence score 0.0 to 100.0%
   int                  touchCount;
   int                  retestCount;
   int                  mergeCount;

   // Associated IDs & Metadata
   ulong                mergedIntoId;      ///< ID of zone this was merged into
   string               metadataJson;      ///< Custom metadata string

   /// @brief Updates midPrice based on upper and lower bounds.
   void CalculateMidPrice()
   {
      midPrice = (upperPrice + lowerPrice) / 2.0;
   }

   /// @brief Gets zone height in price units.
   double Height() const { return MathAbs(upperPrice - lowerPrice); }
};
