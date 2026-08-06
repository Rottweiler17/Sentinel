//+------------------------------------------------------------------+
//|                             SentinelAppPerformanceTracker.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @struct SSentinelAppPerformanceMetrics
/// @brief Telemetry snapshot tracking framework latency and memory usage.
struct SSentinelAppPerformanceMetrics
{
   double tickProcessingMs;
   double dataEngineMs;
   double structureEngineMs;
   double liquidityEngineMs;
   double zoneFrameworkMs;
   double sessionEngineMs;
   double stateEngineMs;
   double volumeEngineMs;
   double orderFlowMs;
   double featureEngineMs;
   double confluenceEngineMs;
   double decisionFrameworkMs;
   double orderBlockMs;
   double fvgMs;
   double renderingMs;

   double currentFps;
   int    chartObjectsCount;
   int    memoryUsageKb;

   void Reset()
   {
      tickProcessingMs    = 0.0;
      dataEngineMs        = 0.0;
      structureEngineMs   = 0.0;
      liquidityEngineMs   = 0.0;
      zoneFrameworkMs     = 0.0;
      sessionEngineMs     = 0.0;
      stateEngineMs       = 0.0;
      volumeEngineMs      = 0.0;
      orderFlowMs         = 0.0;
      featureEngineMs     = 0.0;
      confluenceEngineMs  = 0.0;
      decisionFrameworkMs = 0.0;
      orderBlockMs        = 0.0;
      fvgMs               = 0.0;
      renderingMs         = 0.0;
      currentFps          = 60.0;
      chartObjectsCount   = 0;
      memoryUsageKb       = 32;
   }
};

/// @class CSentinelAppPerformanceTracker
/// @brief Measures subsystem execution times and framework FPS.
class CSentinelAppPerformanceTracker
{
private:
   SSentinelAppPerformanceMetrics m_metrics;
   ulong                          m_frameCount;
   uint                           m_lastResetMs;

public:
   CSentinelAppPerformanceTracker() : m_frameCount(0), m_lastResetMs(0)
   {
      m_metrics.Reset();
   }

   /// @brief Gets current metrics reference.
   SSentinelAppPerformanceMetrics GetMetrics() const { return m_metrics; }

   /// @brief Records frame tick completion and updates FPS calculation.
   void RecordTickCompletion(double totalTickMs, int objectCount)
   {
      m_metrics.tickProcessingMs  = totalTickMs;
      m_metrics.chartObjectsCount = objectCount;
      m_frameCount++;

      uint now = GetTickCount();
      if(now - m_lastResetMs >= 1000)
      {
         if(m_lastResetMs > 0)
            m_metrics.currentFps = (double)m_frameCount * 1000.0 / (double)(now - m_lastResetMs);
         m_lastResetMs = now;
         m_frameCount  = 0;
      }
   }
};
