# PROJECT SENTINEL: Phase 1 - Foundation Architecture (Verified Clean)

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: CLEANED, VERIFIED & COMPLETED (2026-08-05)  

---

## 1. Directory Responsibility Breakdown

The framework foundation is cleanly divided with **zero overlapping files**:

### A. Common Layer (`Include/SENTINEL/Common/`)
*Reserved strictly for shared contracts, data types, enumerations, and system constants:*
- **`Constants.mqh`**: System limits, buffer capacities, status codes (`ENUM_SENTINEL_STATUS`), safety macros.
- **`Defs.mqh`**: Core macro definitions.
- **`Types.mqh`**: All domain structs (`SBarData`, `STickData`, `SSwingPoint`, `SZoneData`, `SSignalData`, `SMarketRegimeData`, `SSessionData`, `SRiskData`, `SVolumeProfileData`, `SDeltaData`, `SAbsorptionData`, `SDecisionData`).
- **`Interfaces.mqh`**: Pure abstract contracts (`IEngine`, `IEventListener`, `IModule`, `IDrawable`) and categorized event types (`EVENT_SYS_*`, `EVENT_MKT_*`, `EVENT_TRD_*`, `EVENT_UI_*`).

### B. Utilities Layer (`Include/SENTINEL/Utilities/`)
*Reserved strictly for helper functions and utility implementations:*
- **`MathUtils.mqh`**: Pip value calculation, R-Multiple calculation, lot sizing math, price clamping.
- **[TimeUtils.mqh](file:///d:/Trading/Project%20Sentinel/Include/SENTINEL/Utilities/TimeUtils.mqh)**: Session evaluation (Asian, London, NY, Kill Zones), bar time rounding, new bar check.
- **[StringUtils.mqh](file:///d:/Trading/Project%20Sentinel/Include/SENTINEL/Utilities/StringUtils.mqh)**: Trimming, casing, number formatting.
- **[Validation.mqh](file:///d:/Trading/Project%20Sentinel/Include/SENTINEL/Utilities/Validation.mqh)**: Pointer, price, symbol, and string validation helpers.
- **[ArrayUtils.mqh](file:///d:/Trading/Project%20Sentinel/Include/SENTINEL/Utilities/ArrayUtils.mqh)**: Binary search & fast array element removal.

### C. Core Layer (`Include/SENTINEL/Core/`)
*Reserved for versioning, build metadata, and base classes:*
- **`Version.mqh`**: Centralized version specification (`1.0.0`).
- **`BuildInfo.mqh`**: Build metadata (`SENTINEL_BUILD_NUMBER`, build date/time).
- **`BaseEngine.mqh`**: Abstract `CBaseEngine` base class supporting dependency injection.
- **`BaseModule.mqh`**: Abstract `CBaseModule` base class supporting dependency injection.

---

## 2. Directory Layout Verification

```
Include/SENTINEL/
├── Common/              # [SHARED DEFINITIONS & CONTRACTS ONLY]
│   ├── Constants.mqh
│   ├── Defs.mqh
│   ├── Interfaces.mqh
│   └── Types.mqh
├── Utilities/           # [HELPER IMPLEMENTATIONS ONLY]
│   ├── ArrayUtils.mqh
│   ├── MathUtils.mqh
│   ├── StringUtils.mqh
│   ├── TimeUtils.mqh
│   └── Validation.mqh
├── Core/
│   ├── Version.mqh
│   ├── BuildInfo.mqh
│   ├── BaseEngine.mqh
│   └── BaseModule.mqh
├── Config/
│   ├── ConfigParam.mqh
│   └── ConfigEngine.mqh
├── Logging/
│   ├── LogLevel.mqh
│   └── Logger.mqh
├── Memory/
│   ├── RingBuffer.mqh
│   └── ObjectPool.mqh
└── Tests/
    └── FoundationTest.mqh
```

---

> [!IMPORTANT]
> **Foundation Cleanup is 100% verified with zero duplication between Common/ and Utilities/.**
> Implementation has stopped. We await your approval before beginning Phase 2.
