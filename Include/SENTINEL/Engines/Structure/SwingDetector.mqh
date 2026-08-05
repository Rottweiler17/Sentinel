//+------------------------------------------------------------------+
//|                                                SwingDetector.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "StructureTypes.mqh"
#include "StructureValidator.mqh"
#include "SwingClassifier.mqh"

/// @class CSwingDetector
/// @brief Configurable swing high/low pivot detector.
class CSwingDetector
{
private:
   int   m_swingLength;
   ulong m_nextSwingId;

public:
   CSwingDetector(int swingLength = 5)
      : m_swingLength(swingLength > 0 ? swingLength : 5), m_nextSwingId(1)
   {}

   void SetSwingLength(int length)
   {
      m_swingLength = (length > 0 ? length : 5);
   }

   int SwingLength() const { return m_swingLength; }

   /// @brief Evaluates price candle array for Swing High at specified index.
   bool IsSwingHigh(const SBarData &bars[], int index, int totalBars)
   {
      if(index < m_swingLength || index >= totalBars - m_swingLength)
         return false;

      double targetHigh = bars[index].high;

      for(int i = 1; i <= m_swingLength; i++)
      {
         if(bars[index - i].high >= targetHigh || bars[index + i].high > targetHigh)
            return false;
      }
      return true;
   }

   /// @brief Evaluates price candle array for Swing Low at specified index.
   bool IsSwingLow(const SBarData &bars[], int index, int totalBars)
   {
      if(index < m_swingLength || index >= totalBars - m_swingLength)
         return false;

      double targetLow = bars[index].low;

      for(int i = 1; i <= m_swingLength; i++)
      {
         if(bars[index - i].low <= targetLow || bars[index + i].low < targetLow)
            return false;
      }
      return true;
   }

   /// @brief Builds a SSwingPoint struct.
   SSwingPoint CreateSwing(const SBarData &bar, int barIndex, ENUM_SWING_TYPE type, ENUM_TIMEFRAMES tf)
   {
      SSwingPoint swing;
      swing.id        = m_nextSwingId++;
      swing.time      = bar.time;
      swing.barIndex  = barIndex;
      swing.price     = (type == SWING_TYPE_HIGH) ? bar.high : bar.low;
      swing.type      = type;
      swing.timeframe = tf;
      swing.isBroken  = false;
      swing.breakTime = 0;
      return swing;
   }
};
