//+------------------------------------------------------------------+
//|                                               FoundationTest.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

// All Foundation Layer Headers
#include "../Common/Constants.mqh"
#include "../Common/Validation.mqh"
#include "../Common/StringUtils.mqh"
#include "../Common/MathUtils.mqh"
#include "../Common/TimeUtils.mqh"
#include "../Core/Defs.mqh"
#include "../Core/Types.mqh"
#include "../Core/Interfaces.mqh"
#include "../Core/BaseEngine.mqh"
#include "../Core/BaseModule.mqh"
#include "../Logging/LogLevel.mqh"
#include "../Logging/Logger.mqh"
#include "../Config/ConfigParam.mqh"
#include "../Config/ConfigEngine.mqh"
#include "../Memory/RingBuffer.mqh"
#include "../Memory/ObjectPool.mqh"
#include "../Utilities/ArrayUtils.mqh"

/// @class CFoundationTest
/// @brief Compile verification test harness for Project SENTINEL Foundation.
class CFoundationTest
{
public:
   static bool RunTest()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("TestHarness", "Starting Foundation compilation test...");

      // 1. RingBuffer Test
      CRingBuffer<int> ringBuffer(5, true);
      ringBuffer.Push(10);
      ringBuffer.Push(20);
      int peekVal = 0;
      bool peekSuccess = ringBuffer.Peek(0, peekVal);

      // 2. ObjectPool Test
      CObjectPool<CConfigParam> pool(10, 5);
      CConfigParam *p = pool.Acquire();
      bool releaseSuccess = pool.Release(p);

      // 3. ConfigEngine Test
      CConfigEngine config;
      config.SetInt("system.max_bars", 5000);
      long maxBars = config.GetInt("system.max_bars", 1000);

      // 4. Logger Flush & Shutdown
      CLogger::Flush();
      CLogger::Shutdown();

      return (peekSuccess && releaseSuccess && maxBars == 5000);
   }
};
