//+------------------------------------------------------------------+
//|                                     ConfluenceConfiguration.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ConfluenceTypes.mqh"

/// @struct SConfluenceConfiguration
/// @brief Configuration settings governing Confluence evaluation & weighting.
struct SConfluenceConfiguration
{
   // Source Component Weights [0.0 to 1.0]
   double structureWeight;
   double liquidityWeight;
   double orderBlockWeight;
   double fvgWeight;
   double sessionWeight;
   double stateWeight;
   double volumeWeight;
   double orderFlowWeight;

   // Threshold & Sensitivity Parameters
   double minAlignmentThreshold;   ///< Threshold for classifying alignment as strong [0.0 - 1.0]
   double conflictSensitivity;     ///< Sensitivity multiplier for conflicting evidence [0.5 - 2.0]
   double minConfidenceThreshold;  ///< Minimum overall confidence required for validity

   // Enable Flags per Source
   bool   enableStructure;
   bool   enableLiquidity;
   bool   enableOrderBlocks;
   bool   enableFVG;
   bool   enableSession;
   bool   enableMarketState;
   bool   enableVolume;
   bool   enableOrderFlow;

   /// @brief Default constructor initializing standard default parameters.
   void SetDefaults()
   {
      structureWeight        = 1.0;
      liquidityWeight        = 0.9;
      orderBlockWeight       = 0.85;
      fvgWeight              = 0.8;
      sessionWeight          = 0.6;
      stateWeight            = 0.7;
      volumeWeight           = 0.65;
      orderFlowWeight        = 0.75;

      minAlignmentThreshold  = 0.60;
      conflictSensitivity    = 1.0;
      minConfidenceThreshold = 0.50;

      enableStructure        = true;
      enableLiquidity        = true;
      enableOrderBlocks       = true;
      enableFVG              = true;
      enableSession          = true;
      enableMarketState      = true;
      enableVolume           = true;
      enableOrderFlow        = true;
   }
};
