//+------------------------------------------------------------------+
//|                                                   ArrayUtils.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

/// @class CArrayUtils
/// @brief High-performance template utilities for array binary search and element removal.
class CArrayUtils
{
public:
   /// @brief Performs binary search on an ascending sorted array.
   /// @tparam T Element type.
   /// @param arr Array to search.
   /// @param value Target value.
   /// @return Index if found, -1 if not found.
   template<typename T>
   static int BinarySearchAscending(const T &arr[], const T value)
   {
      int low  = 0;
      int high = ArraySize(arr) - 1;

      while(low <= high)
      {
         int mid = low + (high - low) / 2;
         if(arr[mid] == value)
            return mid;
         if(arr[mid] < value)
            low = mid + 1;
         else
            high = mid - 1;
      }
      return -1;
   }

   /// @brief Performs fast element removal without preserving array ordering (swaps with last element).
   /// @tparam T Element type.
   /// @param arr Array to modify.
   /// @param index Target index to remove.
   template<typename T>
   static void FastRemove(T &arr[], int index)
   {
      int size = ArraySize(arr);
      if(index < 0 || index >= size)
         return;

      if(index < size - 1)
         arr[index] = arr[size - 1];

      ArrayResize(arr, size - 1);
   }
};
