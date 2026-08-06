//+------------------------------------------------------------------+
//|                                           SentinelDeveloper.mq5 |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property copyright "Project SENTINEL Framework"
#property link      "https://github.com/Rottweiler17/Sentinel"
#property version   "1.00"
#property indicator_chart_window
#property strict

#include "SentinelAppEngine.mqh"

// Application Instance
CSentinelAppEngine g_appEngine;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   EventSetTimer(1); // Set 1-second refresh timer for Developer Panel updates

   if(!g_appEngine.InitializeSubsystems(ChartID()))
   {
      Print("[SENTINEL-ERROR] SentinelDeveloper Application Initialization Failed!");
      return(INIT_FAILED);
   }

   Print("[SENTINEL-INIT] SentinelDeveloper Application Ready and Active.");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   g_appEngine.Shutdown();
   Print("[SENTINEL-RUN] SentinelDeveloper Application Deinitialized cleanly.");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   g_appEngine.ProcessTickCycle();
   return(rates_total);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   g_appEngine.OnChartEvent(id, lparam, dparam, sparam);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   // Refresh Developer Panel telemetry
   SMarketContext context = g_appEngine.GetContext();
   SSentinelAppPerformanceMetrics perf = g_appEngine.GetPerformanceMetrics();
   SVisualizationSnapshot visSnap = g_appEngine.GetVisualizationSnapshot();

   string panelText = CSentinelAppMenu::FormatDeveloperPanel(context, perf, visSnap);
   Comment(panelText);
}
//+------------------------------------------------------------------+
