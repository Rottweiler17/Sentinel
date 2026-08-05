//+------------------------------------------------------------------+
//|                                                CHOCHDetector.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "StructureTypes.mqh"
#include "StructureValidator.mqh"

/// @class CCHOCHDetector
/// @brief Detects Change of Character (CHOCH) trend reversal events.
class CCHOCHDetector
{
private:
   ulong m_nextCHOCHId;

public:
   CCHOCHDetector() : m_nextCHOCHId(1) {}

   /// @brief Evaluates current bar close against last counter-trend swing point for CHOCH.
   bool DetectCHOCH(const SBarData &currentBar, const SSwingPoint &lastSwing, ENUM_TREND_TYPE currentTrend, SCHOCHData &outCHOCH)
   {
      if(!CStructureValidator::IsValidSwing(lastSwing)) return false;

      // Bullish CHOCH (Price breaks above last Swing High during Bearish Trend)
      if(currentTrend == TREND_BEARISH && lastSwing.type == SWING_TYPE_HIGH && currentBar.close > lastSwing.price)
      {
         outCHOCH.id               = m_nextCHOCHId++;
         outCHOCH.type             = BREAK_CHOCH_BULLISH;
         outCHOCH.time             = currentBar.time;
         outCHOCH.breakPrice       = currentBar.close;
         outCHOCH.brokenSwingPrice = lastSwing.price;
         outCHOCH.timeframe        = lastSwing.timeframe;
         return true;
      }

      // Bearish CHOCH (Price breaks below last Swing Low during Bullish Trend)
      if(currentTrend == TREND_BULLISH && lastSwing.type == SWING_TYPE_LOW && currentBar.close < lastSwing.price)
      {
         outCHOCH.id               = m_nextCHOCHId++;
         outCHOCH.type             = BREAK_CHOCH_BEARISH;
         outCHOCH.time             = currentBar.time;
         outCHOCH.breakPrice       = currentBar.close;
         outCHOCH.brokenSwingPrice = lastSwing.price;
         outCHOCH.timeframe        = lastSwing.timeframe;
         return true;
      }

      return false;
   }
};
