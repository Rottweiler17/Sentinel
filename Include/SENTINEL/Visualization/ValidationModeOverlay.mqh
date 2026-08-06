//+------------------------------------------------------------------+
//|                                        ValidationModeOverlay.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Framework/Context/MarketContext.mqh"
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
      s += StringFormat("1. MarketDataSnapshot:  Timestamp=%s, High=%.5f, Low=%.5f, Close=%.5f\n", TimeToString(context.timestamp), context.marketData.high, context.marketData.low, context.marketData.close);
      s += StringFormat("2. StructureSnapshot:   Trend=%d, SwingHighs=%d, SwingLows=%d\n", context.structure.trend, context.structure.swingHighCount, context.structure.swingLowCount);
      s += StringFormat("3. LiquiditySnapshot:   SSL Sweep=%s, BSL Sweep=%s\n", (context.liquidity.sellSideSweepActive?"YES":"NO"), (context.liquidity.buySideSweepActive?"YES":"NO"));
      s += StringFormat("4. ZoneSnapshot:        Active Zones=%d\n", context.zones.activeZoneCount);
      s += StringFormat("5. SessionSnapshot:     SessionType=%d, Bias=%.2f\n", context.session.sessionType, context.session.directionalBias);
      s += StringFormat("6. MarketStateSnapshot: StateType=%d, Duration=%d\n", context.state.stateType, context.state.stateDurationBars);
      s += StringFormat("7. VolumeSnapshot:      VolumeStrength=%.2f, RelativeVolume=%.2f\n", context.volume.volumeStrength, context.volume.relativeVolume);
      s += StringFormat("8. OrderFlowSnapshot:   Delta=%.2f, Imbalance=%.2f\n", context.orderFlow.delta, context.orderFlow.imbalance);
      s += StringFormat("9. FeatureSnapshot:     StructureScore=%.2f, LiquidityScore=%.2f\n", context.features.structureScore.normalizedValue, context.features.liquidityScore.normalizedValue);
      s += StringFormat("10. ConfluenceSnapshot: OverallScore=%.3f, Alignment=%.2f, Conflict=%.2f\n", context.confluence.overallConfluenceScore, context.confluence.alignmentScore, context.confluence.conflictScore);
      s += StringFormat("11. DecisionSnapshot:   CompositeScore=%.3f, Confidence=%.2f\n", context.decisions.compositeScore, context.decisions.confidence);
      s += StringFormat("12. OrderBlockSnapshot: BullishOB=%d, BearishOB=%d\n", context.orderBlocks.activeBullishObCount, context.orderBlocks.activeBearishObCount);
      s += StringFormat("13. FVGSnapshot:        UnfilledBullish=%d, UnfilledBearish=%d\n", context.fairValueGaps.unfilledBullishFvgCount, context.fairValueGaps.unfilledBearishFvgCount);
      return s;
   }
};
