//+------------------------------------------------------------------+
//|                                                   Validation.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "Constants.mqh"

/// @class CValidation
/// @brief Static helper functions for verifying pointer validity, price bounds, and handle integrity.
class CValidation
{
public:
   /// @brief Check if a pointer is a valid dynamic or static object.
   static bool IsValidPointer(const void *ptr)
   {
      return (CheckPointer(ptr) != POINTER_INVALID);
   }

   /// @brief Check if a string parameter is non-empty.
   static bool IsNonEmptyString(const string str)
   {
      return (StringLen(str) > 0);
   }

   /// @brief Check if a price value is positive and non-zero.
   static bool IsValidPrice(const double price)
   {
      return (price > 0.0 && MathIsValidNumber(price));
   }

   /// @brief Check if a chart symbol is recognized by the terminal.
   static bool IsValidSymbol(const string symbol)
   {
      return (SymbolInfoInteger(symbol, SYMBOL_SELECT) || SymbolSelect(symbol, true));
   }
};
