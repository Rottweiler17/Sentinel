//+------------------------------------------------------------------+
//|                                                    MathUtils.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CMathUtils
/// @brief Pure mathematical, price clamping, lot sizing, and R-Multiple utilities.
class CMathUtils
{
public:
   /// @brief Clamps a value between minVal and maxVal.
   static double Clamp(double value, double minVal, double maxVal)
   {
      if(value < minVal) return minVal;
      if(value > maxVal) return maxVal;
      return value;
   }

   /// @brief Normalizes a price value according to symbol digit precision.
   static double NormalizePrice(double price, string symbol)
   {
      double digits = (double)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      return NormalizeDouble(price, (int)digits);
   }

   /// @brief Calculates the monetary value of 1 pip for a specific symbol and lot size.
   static double CalculatePipValue(string symbol, double lotSize = 1.0)
   {
      double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

      if(tickSize <= 0.0 || point <= 0.0)
         return 0.0;

      return (tickValue / tickSize) * point * 10.0 * lotSize;
   }

   /// @brief Calculates the R-Multiple achieved for a trade setup.
   static double CalculateRMultiple(double entryPrice, double exitPrice, double stopLossPrice, bool isLong)
   {
      double risk = MathAbs(entryPrice - stopLossPrice);
      if(risk <= 0.0) return 0.0;

      double reward = isLong ? (exitPrice - entryPrice) : (entryPrice - exitPrice);
      return reward / risk;
   }

   /// @brief Calculates lot size based on account balance, risk percentage, and stop loss.
   static double CalculatePositionSize(double accountBalance, double riskPercent, double stopLossPips, string symbol)
   {
      if(stopLossPips <= 0.0 || accountBalance <= 0.0 || riskPercent <= 0.0)
         return 0.01;

      double riskAmount = accountBalance * (riskPercent / 100.0);
      double pipValue   = CalculatePipValue(symbol, 1.0);

      if(pipValue <= 0.0) return 0.01;

      double rawLot = riskAmount / (stopLossPips * pipValue);
      double stepLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      double minLot  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double maxLot  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);

      if(stepLot > 0.0)
         rawLot = MathFloor(rawLot / stepLot) * stepLot;

      return Clamp(rawLot, minLot, maxLot);
   }
};
