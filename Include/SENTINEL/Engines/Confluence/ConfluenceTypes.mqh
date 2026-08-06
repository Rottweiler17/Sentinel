//+------------------------------------------------------------------+
//|                                             ConfluenceTypes.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @enum ENUM_EVIDENCE_SOURCE
/// @brief Independent analytical components providing evidence.
enum ENUM_EVIDENCE_SOURCE
{
   EVIDENCE_MARKET_STRUCTURE = 0,
   EVIDENCE_LIQUIDITY,
   EVIDENCE_ORDER_BLOCK,
   EVIDENCE_FVG,
   EVIDENCE_SESSION,
   EVIDENCE_MARKET_STATE,
   EVIDENCE_VOLUME,
   EVIDENCE_ORDER_FLOW,
   EVIDENCE_SOURCE_COUNT
};

/// @enum ENUM_CONFLUENCE_BIAS
/// @brief Directional alignment bias.
enum ENUM_CONFLUENCE_BIAS
{
   BIAS_BEARISH = -1,
   BIAS_NEUTRAL = 0,
   BIAS_BULLISH = 1
};

/// @enum ENUM_CONFLUENCE_STRENGTH
/// @brief Categorical strength classification of evidence confluence.
enum ENUM_CONFLUENCE_STRENGTH
{
   CONFLUENCE_NONE = 0,
   CONFLUENCE_WEAK,
   CONFLUENCE_MODERATE,
   CONFLUENCE_STRONG,
   CONFLUENCE_EXTREME
};

/// @struct SEvidenceFactor
/// @brief Struct representing a single standardized evidence factor from an analytical module.
struct SEvidenceFactor
{
   ENUM_EVIDENCE_SOURCE source;
   ENUM_CONFLUENCE_BIAS bias;
   double               weight;        ///< Component weight factor [0.0 - 1.0]
   double               confidence;    ///< Source confidence [0.0 - 1.0]
   double               score;         ///< Directional contribution [-1.0 - +1.0]
   string               description;   ///< Descriptive factor summary

   void Reset()
   {
      source      = EVIDENCE_MARKET_STRUCTURE;
      bias        = BIAS_NEUTRAL;
      weight      = 0.0;
      confidence  = 0.0;
      score       = 0.0;
      description = "";
   }
};
