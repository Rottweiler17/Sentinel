//+------------------------------------------------------------------+
//|                                             FeatureExtractor.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
#include "FeatureTypes.mqh"
#include "FeatureCalculator.mqh"

/// @class CFeatureExtractor
/// @brief Extracts all engine outputs and transforms them into standardized features.
class CFeatureExtractor
{
public:
   static void Extract(const SMarketContext &context, SFeatureSnapshot &outFeatures, const CFeatureConfiguration &config)
   {
      // 1. Structure Features
      outFeatures.trendStrength  = CFeatureCalculator::CreateFeature(context.structure.trendStrength, 0.0, 100.0, 95.0, 1, config);
      outFeatures.structureScore = CFeatureCalculator::CreateFeature((double)context.structure.externalTrend, -1.0, 2.0, 90.0, 1, config);

      // 2. Liquidity Features
      outFeatures.liquidityScore      = CFeatureCalculator::CreateFeature(context.liquidity.liquidityQualityScore, 0.0, 100.0, 85.0, 2, config);
      outFeatures.liquiditySweepScore = CFeatureCalculator::CreateFeature((double)context.liquidity.latestSweep.sweepType, 0.0, 4.0, 80.0, 2, config);

      // 3. Zone Features
      outFeatures.zoneStrength  = CFeatureCalculator::CreateFeature((double)context.zones.activeZonesCount, 0.0, 50.0, 85.0, 3, config);
      outFeatures.zoneFreshness = CFeatureCalculator::CreateFeature(50.0, 0.0, 100.0, 70.0, 3, config);

      // 4. Session Features
      outFeatures.sessionWeight = CFeatureCalculator::CreateFeature((double)context.session.currentSession, 0.0, 6.0, 99.0, 4, config);

      // 5. Volume Features
      outFeatures.volumeStrength = CFeatureCalculator::CreateFeature((double)context.volume.currentRealVolume, 0.0, 10000.0, 90.0, 5, config);
      outFeatures.relativeVolume = CFeatureCalculator::CreateFeature(context.volume.relativeVolume, 0.0, 10.0, 90.0, 5, config);

      // 6. Order Flow Features
      outFeatures.buyingPressure     = CFeatureCalculator::CreateFeature(context.orderFlow.buyingPressure, 0.0, 100.0, 75.0, 6, config);
      outFeatures.sellingPressure    = CFeatureCalculator::CreateFeature(context.orderFlow.sellingPressure, 0.0, 100.0, 75.0, 6, config);
      outFeatures.participationScore = CFeatureCalculator::CreateFeature(context.orderFlow.participationScore, 0.0, 100.0, 75.0, 6, config);

      // 7. Market State Features
      outFeatures.marketStateScore   = CFeatureCalculator::CreateFeature((double)context.state.currentState, 0.0, 30.0, 85.0, 7, config);

      // Aggregates
      outFeatures.overallConfidence = 85.0;
      outFeatures.reliability       = 80.0;
      outFeatures.dataCompleteness  = 100.0;
      outFeatures.timestamp         = context.timestamp;
   }
};
