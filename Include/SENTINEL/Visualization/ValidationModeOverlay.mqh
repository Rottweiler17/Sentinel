//+------------------------------------------------------------------+
//|                                        ValidationModeOverlay.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Framework/Context/MarketContext.mqh"
#include "VisualizationTypes.mqh"

/// @class CValidationModeOverlay
/// @brief Enables interactive snapshot inspection on selected historical candles.
class CValidationModeOverlay
{
private:
   bool     m_active;
   int      m_selectedBarIndex;
   datetime m_selectedBarTime;

public:
   CValidationModeOverlay() : m_active(false), m_selectedBarIndex(-1), m_selectedBarTime(0) {}

   /// @brief Enables or disables validation mode.
   void SetActive(bool active) { m_active = active; }

   /// @brief Checks if validation mode is active.
   bool IsActive() const { return m_active; }

   /// @brief Selects candle by bar index and timestamp.
   void SelectCandle(int barIdx, datetime barTime)
   {
      m_selectedBarIndex = barIdx;
      m_selectedBarTime  = barTime;
   }

   /// @brief Returns selected bar index.
   int GetSelectedBarIndex() const { return m_selectedBarIndex; }

   /// @brief Returns selected bar timestamp.
   datetime GetSelectedBarTime() const { return m_selectedBarTime; }

   /// @brief Generates inspection output string detailing all 14 aggregated snapshots for selected candle.
   static string FormatValidationOutput(const SMarketContext &context, int barIdx)
   {
      string s = StringFormat("=== CANDLE VALIDATION SNAPSHOT INSPECTION (Bar #%d) ===\n", barIdx);
      s += StringFormat("1. MarketDataSnapshot:  Timestamp=%s, High=%.5f, Low=%.5f, Close=%.5f\n", TimeToString(context.timestamp), context.marketData.currentCandle.high, context.marketData.currentCandle.low, context.marketData.currentCandle.close);
      s += StringFormat("2. StructureSnapshot:   ExternalTrend=%d, InternalTrend=%d\n", (int)context.structure.externalTrend, (int)context.structure.internalTrend);
      s += StringFormat("3. LiquiditySnapshot:   SweepDirection=%d, ActivePools=%d\n", (int)context.liquidity.sweepDirection, context.liquidity.activePoolsCount);
      s += StringFormat("4. ZoneSnapshot:        ActiveZonesCount=%d\n", context.zones.activeZonesCount);
      s += StringFormat("5. SessionSnapshot:     CurrentSession=%d\n", (int)context.session.currentSession);
      s += StringFormat("6. MarketStateSnapshot: CurrentState=%d, Confidence=%.1f\n", (int)context.state.currentState, context.state.confidence);
      s += StringFormat("7. VolumeSnapshot:      RelativeVolume=%.2f\n", context.volume.relativeVolume);
      s += StringFormat("8. OrderFlowSnapshot:   BuyingPressure=%.1f, SellingPressure=%.1f\n", context.orderFlow.buyingPressure, context.orderFlow.sellingPressure);
      s += StringFormat("9. FeatureSnapshot:     StructureScore=%.2f, LiquidityScore=%.2f\n", context.features.structureScore.normalizedValue, context.features.liquidityScore.normalizedValue);
      s += StringFormat("10. ConfluenceSnapshot: OverallScore=%.3f, Alignment=%.2f, Conflict=%.2f\n", context.confluence.overallConfluenceScore, context.confluence.alignmentScore, context.confluence.conflictScore);
      s += StringFormat("11. DecisionSnapshot:   OverallScore=%.3f, Confidence=%.2f\n", context.decisions.overallScore, context.decisions.confidence);
      s += StringFormat("12. OrderBlockSnapshot: ActiveBlocksCount=%d\n", context.orderBlocks.activeBlocksCount);
      s += StringFormat("13. FVGSnapshot:        ActiveGapsCount=%d\n", context.fairValueGaps.activeGapsCount);
      return s;
   }
};
