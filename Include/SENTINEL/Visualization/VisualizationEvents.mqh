//+------------------------------------------------------------------+
//|                                          VisualizationEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "VisualizationTypes.mqh"
#include "ValidationModeOverlay.mqh"

/// @class CVisualizationEvents
/// @brief Intercepts chart events (CHARTEVENT_CLICK, CHARTEVENT_KEYDOWN) for layer toggling & validation mode.
class CVisualizationEvents
{
public:
   /// @brief Processes raw MQL5 chart event.
   static bool OnChartEvent(const int id,
                            const long &lparam,
                            const double &dparam,
                            const string &sparam,
                            CValidationModeOverlay &validationOverlay)
   {
      if(id == CHARTEVENT_CLICK)
      {
         // Convert x, y pixel click coordinates into time & bar index for Validation Mode
         int subWindow = 0;
         datetime timeVal = 0;
         double priceVal = 0.0;

         if(ChartXYToTimePrice(0, (int)lparam, (int)dparam, subWindow, timeVal, priceVal))
         {
            int barIdx = iBarShift(_Symbol, _Period, timeVal, false);
            if(barIdx >= 0)
            {
               validationOverlay.SelectCandle(barIdx, timeVal);
               return true;
            }
         }
      }
      return false;
   }
};
