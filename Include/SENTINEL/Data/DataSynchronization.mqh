//+------------------------------------------------------------------+
//|                                          DataSynchronization.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "BarCache.mqh"
#include "SeriesValidation.mqh"

/// @class CDataSynchronization
/// @brief Synchronizes bar history from MT5 API into CBarCache without freezing execution.
class CDataSynchronization
{
public:
   /// @brief Syncs bar history for symbol and timeframe into target CBarCache.
   static bool SyncHistory(const string symbol, ENUM_TIMEFRAMES tf, CBarCache &cache, int count = 500)
   {
      if(cache == NULL) return false;

      MqlRates rates[];
      ArraySetAsSeries(rates, true);

      int copied = CopyRates(symbol, tf, 0, count, rates);
      if(copied <= 0) return false;

      cache.Clear();
      for(int i = copied - 1; i >= 0; i--)
      {
         SBarData bar;
         bar.time        = rates[i].time;
         bar.open        = rates[i].open;
         bar.high        = rates[i].high;
         bar.low         = rates[i].low;
         bar.close       = rates[i].close;
         bar.tick_volume = rates[i].tick_volume;
         bar.spread      = rates[i].spread;
         bar.real_volume = rates[i].real_volume;

         if(CSeriesValidation::IsValidBar(bar))
         {
            cache.AddBar(bar);
         }
      }

      ArrayFree(rates);
      return (cache.Size() > 0);
   }
};
