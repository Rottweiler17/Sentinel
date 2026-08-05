//+------------------------------------------------------------------+
//|                                                  BOSDetector.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "StructureTypes.mqh"
#include "StructureValidator.mqh"

/// @class CBOSDetector
/// @brief Detects Break of Structure (BOS) events in trend continuation direction.
class CBOSDetector
{
private:
   ulong m_nextBOSId;

public:
   CBOSDetector() : m_nextBOSId(1) {}

   /// @brief Evaluates current bar close against last swing point for BOS.
   bool DetectBOS(const SBarData &currentBar, const SSwingPoint &lastSwing, ENUM_TREND_TYPE currentTrend, SBOSData &outBOS)
   {
      if(!CStructureValidator::IsValidSwing(lastSwing)) return false;

      // Bullish Continuation BOS
      if(currentTrend == TREND_BULLISH && lastSwing.type == SWING_TYPE_HIGH && currentBar.close > lastSwing.price)
      {
         outBOS.id               = m_nextBOSId++;
         outBOS.type             = BREAK_BOS_BULLISH;
         outBOS.time             = currentBar.time;
         outBOS.breakPrice       = currentBar.close;
         outBOS.brokenSwingPrice = lastSwing.price;
         outBOS.timeframe        = lastSwing.timeframe;
         outBOS.isMajor          = true;
         return true;
      }

      // Bearish Continuation BOS
      if(currentTrend == TREND_BEARISH && lastSwing.type == SWING_TYPE_LOW && currentBar.close < lastSwing.price)
      {
         outBOS.id               = m_nextBOSId++;
         outBOS.type             = BREAK_BOS_BEARISH;
         outBOS.time             = currentBar.time;
         outBOS.breakPrice       = currentBar.close;
         outBOS.brokenSwingPrice = lastSwing.price;
         outBOS.timeframe        = lastSwing.timeframe;
         outBOS.isMajor          = true;
         return true;
      }

      return false;
   }
};
