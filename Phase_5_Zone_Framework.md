# PROJECT SENTINEL: Phase 5 - Generic Zone Framework & Interface Contracts

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: COMPLETED & VERIFIED (2026-08-05)  

---

## 1. Executive Summary

Phase 5 creates the **Generic Zone Framework** (`CZoneEngine`). It serves as the enterprise-grade foundation for every price zone concept inside SENTINEL without embedding strategy-specific logic (no Order Blocks, Fair Value Gaps, or Supply/Demand rules are hardcoded).

Additionally, **Stable Public Interfaces** are now exposed for every major subsystem:
1. `IStructureEngine`: Declared in [IStructureEngine.mqh](file:///d:/Trading/Project%20Sentinel/Include/SENTINEL/Engines/Structure/IStructureEngine.mqh).
2. `ILiquidityEngine`: Declared in [ILiquidityEngine.mqh](file:///d:/Trading/Project%20Sentinel/Include/SENTINEL/Engines/Liquidity/ILiquidityEngine.mqh).
3. `IZoneEngine`: Declared in [IZoneEngine.mqh](file:///d:/Trading/Project%20Sentinel/Include/SENTINEL/Framework/Zones/IZoneEngine.mqh).

Concrete engines implement these contracts directly. This decouples future strategy development from implementation details and enables mock testing.

---

## 2. Folder Tree & New Components

```
Include/SENTINEL/
├── Engines/
│   ├── Structure/
│   │   └── IStructureEngine.mqh           # Public interface for Structure Engine
│   └── Liquidity/
│       └── ILiquidityEngine.mqh           # Public interface for Liquidity Engine
│
└── Framework/
    └── Zones/
        ├── IZoneEngine.mqh                # Public interface for Zone Framework
        ├── ZoneTypes.mqh                 # Enums (Category, Lifecycle, Priority) & SGenericZone model
        ├── ZoneConfiguration.mqh          # CZoneConfiguration (min/max height, age, overlap %)
        ├── ZoneEvents.mqh                 # CZoneEvents payload factory
        ├── ZoneSnapshot.mqh               # Immutable SZoneSnapshot model with versioning
        ├── ZoneCache.mqh                  # CZoneCache ring buffer storage for active, historical & expired zones
        ├── ZoneRepository.mqh             # CZoneRepository zone lookup container
        ├── ZoneHistory.mqh                # CZoneHistory zone snapshot ring buffer history
        ├── ZoneValidator.mqh              # CZoneValidator generic zone rule checker
        ├── ZoneMerger.mqh                 # CZoneMerger overlapping zone merger
        ├── ZoneSplitter.mqh               # CZoneSplitter partial penetration splitter
        ├── ZoneClassifier.mqh             # CZoneClassifier category & priority evaluator
        ├── ZoneFactory.mqh                # CZoneFactory generic zone constructor
        ├── ZoneLifecycleManager.mqh       # CZoneLifecycleManager lifecycle state transition coordinator
        ├── ZoneManager.mqh                # CZoneManager zone collection manager
        ├── ZoneStatistics.mqh             # CZoneStatistics zone count & quality score telemetry
        └── ZoneEngine.mqh                 # CZoneEngine master generic zone framework engine
```

---

## 3. stable Public Interfaces

- **`IStructureEngine`**: Exposes `GetSnapshot()`, `ProcessStructure()`, and `RegisterSwing()`.
- **`ILiquidityEngine`**: Exposes `GetSnapshot()` and `ProcessLiquidity()`.
- **`IZoneEngine`**: Exposes `GetSnapshot()`, `ProcessZones()`, and `RegisterZone()`.

---

## 4. Verification

`Phase5DemoTest.mqh` verifies:
- End-to-end snapshots ingestion $\rightarrow$ Interface-compliant `ZoneEngine` $\rightarrow$ Validated zone creation $\rightarrow$ EventBus publication $\rightarrow$ TestListener logging.

---

> [!IMPORTANT]
> **Phase 5 and stable public interface decoupling are complete.**
> We are ready to begin Phase 6 upon your request.
