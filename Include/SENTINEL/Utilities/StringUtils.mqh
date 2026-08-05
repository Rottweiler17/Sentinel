//+------------------------------------------------------------------+
//|                                                  StringUtils.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CStringUtils
/// @brief Static helper functions for string formatting, trimming, and searching.
class CStringUtils
{
public:
   /// @brief Trims leading and trailing whitespace from a string.
   static string Trim(string str)
   {
      StringTrimLeft(str);
      StringTrimRight(str);
      return str;
   }

   /// @brief Converts string to uppercase.
   static string ToUpper(string str)
   {
      StringToUpper(str);
      return str;
   }

   /// @brief Converts string to lowercase.
   static string ToLower(string str)
   {
      StringToLower(str);
      return str;
   }

   /// @brief Formats a double value with a specified number of decimal places.
   static string FormatDouble(double val, int digits = 2)
   {
      return DoubleToString(val, digits);
   }
};
