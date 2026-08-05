//+------------------------------------------------------------------+
//|                                                SymbolManager.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CSymbolManager
/// @brief Caches and exposes symbol specifications without calling MT5 API inside the live tick loop.
class CSymbolManager
{
private:
   string m_symbol;
   int    m_digits;
   double m_point;
   double m_tickSize;
   double m_tickValue;
   bool   m_isTradeable;

public:
   CSymbolManager()
      : m_symbol(""), m_digits(5), m_point(0.00001), m_tickSize(0.00001), m_tickValue(1.0), m_isTradeable(false)
   {}

   /// @brief Initializes symbol properties from MT5 API.
   bool InitSymbol(const string symbol)
   {
      m_symbol      = symbol;
      m_digits      = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      m_point       = SymbolInfoDouble(symbol, SYMBOL_POINT);
      m_tickSize    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      m_tickValue   = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      m_isTradeable = (SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_DISABLED);

      return (m_point > 0.0 && m_tickSize > 0.0);
   }

   string Symbol() const { return m_symbol; }
   int Digits() const { return m_digits; }
   double Point() const { return m_point; }
   double TickSize() const { return m_tickSize; }
   double TickValue() const { return m_tickValue; }
   bool IsTradeable() const { return m_isTradeable; }
};
