//+------------------------------------------------------------------+
//|                                                   ArrayUtils.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

class CArrayUtils
{
public:
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
