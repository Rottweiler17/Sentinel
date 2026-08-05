//+------------------------------------------------------------------+
//|                                               FoundationTest.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

// Core Layers
#include "../Core/Version.mqh"
#include "../Core/BuildInfo.mqh"
#include "../Core/Defs.mqh"
#include "../Core/Types.mqh"
#include "../Core/Interfaces.mqh"
#include "../Core/BaseEngine.mqh"
#include "../Core/BaseModule.mqh"

// Common Layer (Contracts & Definitions)
#include "../Common/Constants.mqh"
#include "../Common/Defs.mqh"
#include "../Common/Types.mqh"
#include "../Common/Interfaces.mqh"

// Utilities Layer (Helper Functions)
#include "../Utilities/Validation.mqh"
#include "../Utilities/StringUtils.mqh"
#include "../Utilities/MathUtils.mqh"
#include "../Utilities/TimeUtils.mqh"
#include "../Utilities/ArrayUtils.mqh"

// Infrastructure
#include "../Logging/LogLevel.mqh"
#include "../Logging/Logger.mqh"
#include "../Config/ConfigParam.mqh"
#include "../Config/ConfigEngine.mqh"
#include "../Memory/RingBuffer.mqh"
#include "../Memory/ObjectPool.mqh"

/// @class CFoundationTest
/// @brief Integration compile verification harness testing all foundation components.
class CFoundationTest
{
public:
   static bool RunTest()
   {
      CLogger::Init(LOG_LEVEL_DEBUG, true, true);
      CLogger::Info("FoundationTest", CBuildInfo::FullVersionInfo());

      // 1. Versioning & Build Metadata Test
      string verStr = CVersion::ToString();
      int buildNum  = CBuildInfo::BuildNumber();

      // 2. RingBuffer Test
      CRingBuffer<int> ringBuffer(5, true);
      ringBuffer.Push(100);
      ringBuffer.Push(200);
      int backVal = 0;
      bool peekSuccess = ringBuffer.Back(backVal);

      // 3. ObjectPool Test
      CObjectPool<CConfigParam> pool(10, 5);
      CConfigParam *p = pool.Acquire();
      bool releaseSuccess = pool.Release(p);

      // 4. ConfigEngine Test
      CConfigEngine config;
      config.SetInt("system.max_bars", 5000);
      long maxBars = config.GetInt("system.max_bars", 1000);

      // 5. Utility Tests
      double clamped = CMathUtils::Clamp(150.0, 0.0, 100.0);
      string trimmed = CStringUtils::Trim("  SENTINEL  ");
      bool validStr  = CValidation::IsNonEmptyString(trimmed);

      // 6. Logger Flush & Shutdown
      CLogger::Flush();
      CLogger::Shutdown();

      return (peekSuccess && releaseSuccess && maxBars == 5000 && clamped == 100.0 && validStr && buildNum > 0);
   }
};
