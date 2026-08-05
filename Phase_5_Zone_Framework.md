# PROJECT SENTINEL: Phase 5 - Generic Zone Framework

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: COMPLETED & VERIFIED (2026-08-05)  

---

## 1. Executive Summary

Phase 5 creates the **Generic Zone Framework** (`CZoneEngine`). It serves as the enterprise-grade foundation for every price zone concept inside SENTINEL without embedding strategy-specific logic (no Order Blocks, Fair Value Gaps, or Supply/Demand rules are hardcoded).

Strict architectural rules enforced:
- Completely generic and reusable (`SGenericZone` model).
- `CZoneEngine` consumes ONLY `SMarketDataSnapshot`, `SStructureSnapshot`, and `SLiquiditySnapshot`.
- It NEVER communicates directly with MT5 API.
- Emits immutable `SZoneSnapshot` objects and publishes events (`EVENT_MKT_ZONE_CREATED`, `EVENT_MKT_ZONE_INVALIDATED`) via `CEventBus`.
- Zero trading, Order Block, FVG, or drawing logic is present.

---

## 2. Folder Tree & New Components

```
Include/SENTINEL/
└── Framework/
    └── Zones/
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

## 3. Class Responsibilities Matrix

| Component / Class | Primary Responsibility | Single Responsibility Principle |
| :--- | :--- | :--- |
| **`CZoneEngine`** | Master orchestrator engine implementing `IEngine` and `IEventListener`. | Generic Zone Gateway |
| **`CZoneFactory`** | Constructs generic `SGenericZone` instances. | Zone Construction |
| **`CZoneManager`** | Manages zone collections, touch retests, overlap merging, and expiration. | Collection Manager |
| **`CZoneLifecycleManager`**| Coordinates explicit lifecycle transitions (`CREATED` $\rightarrow$ `VALIDATED` $\rightarrow$ `ACTIVE` $\rightarrow$ `RETESTED` $\rightarrow$ `MERGED` $\rightarrow$ `MITIGATED` $\rightarrow$ `CONSUMED` $\rightarrow$ `EXPIRED`). | Lifecycle Management |
| **`CZoneCache`** | Fast $O(1)$ ring buffer storage for active, merged, and expired zones. | Data Storage |
| **`CZoneRepository`**| Enables zone lookups by ID and price range criteria. | Zone Lookup |
| **`CZoneHistory`** | Ring buffer storage for `SZoneSnapshot` sequence history. | History Tracking |
| **`CZoneValidator`**| Validates zone min/max height in pips, min age, and price boundaries. | Zone Validation |
| **`CZoneMerger`** | Merges overlapping zones exceeding configured overlap percentage threshold. | Zone Merging |
| **`CZoneSplitter`**| Adjusts zone boundaries upon partial penetration. | Zone Boundary Splitting |
| **`CZoneClassifier`**| Evaluates priority ratings (`LOW` to `CRITICAL`). | Priority Classification |
| **`CZoneConfiguration`**| Configurable threshold container for zone height, age, and overlap %. | Configuration Settings |
| **`SZoneSnapshot`** | Immutable snapshot object emitted when generic zones update. | Data Snapshot Model |
| **`CZoneEvents`** | Constructs event payloads for EventBus publication. | Event Payload Factory |
| **`CZoneStatistics`** | Tracks active count, retested count, merged count, and quality score. | Telemetry & Performance Stats |

---

## 4. Architectural & Data Flow Diagrams

### Zone Framework Pipeline Flow
```
[MarketDataSnapshot] --+
                       |
[StructureSnapshot] ---+---> [CZoneEngine]
                       |          |
[LiquiditySnapshot] ---+          v
                        Generic Zone Processing (Creation, Validation, Merge, Retest)
                                  |
               +------------------+------------------+
               |                                     |
               v                                     v
 [SZoneSnapshot (Immutable)]              [EventBus Publish]
               |                          (EVENT_MKT_ZONE_CREATED,
               v                           EVENT_MKT_ZONE_INVALIDATED)
  Consumed by Future Modules
  (Order Blocks, FVG, Supply/Demand)
```

### Lifecycle Transition State Machine
```
[CREATED] ---> [VALIDATED] ---> [ACTIVE] ---> [RETESTED] ---> [MITIGATED] ---> [CONSUMED]
                                   |              |
                                   v              v
                               [MERGED]       [EXPIRED]
```

### Snapshot Structure Diagram
```
+-------------------------------------------------------------------------+
|                              SZoneSnapshot                              |
+-------------------------------------------------------------------------+
| Versioning       : snapshotId, parentId, sequenceNumber                 |
| Nearest Zones    : Nearest Support (below price), Nearest Resistance    |
| Counts           : activeZonesCount, retestedZonesCount, mergedZonesCount|
| Telemetry        : zoneQualityScore, timestamp, timeframe                |
+-------------------------------------------------------------------------+
```

---

## 5. Performance Notes & Memory Strategy

- **Zero Allocation in Tick Loop**: Active zones, merged zones, and expired zones operate on static `CRingBuffer` instances in `CZoneCache`.
- **Latency Target**: Zone processing latency $< 0.05$ ms per tick.
- **MT5 API Restriction**: `CZoneEngine` never invokes MT5 API functions. Inputs are derived from `SMarketDataSnapshot`, `SStructureSnapshot`, and `SLiquiditySnapshot`.

---

## 6. Demonstration & Unit Verification

`Phase5DemoTest.mqh` verifies the entire Generic Zone Framework pipeline:
1. Core engines (`DataEngine`, `StructureEngine`, `LiquidityEngine`, `ZoneEngine`) initialized.
2. Listener subscribes to `EVENT_MKT_ZONE_CREATED` and `EVENT_MKT_ZONE_INVALIDATED`.
3. Generic support and resistance zones created from structure swings.
4. Zones validated, transitioned to `ACTIVE`, checked for retests, and updated in `SZoneSnapshot`.
5. Emits `SZoneSnapshot` and dispatches event payloads through `CEventBus`.

---

## 7. Future Extension Points

Future modules in Phase 6 will inherit from or compose `CZoneEngine` via `SGenericZone`:
- **OrderBlockEngine**: Instantiates `SGenericZone` with `ZONE_CATEGORY_DEMAND/SUPPLY` and sets metadata JSON with order block candle specs.
- **FVGEngine**: Instantiates `SGenericZone` with `ZONE_CATEGORY_NEUTRAL` and sets FVG gap boundaries.
- **SupplyDemandEngine**: Consolidates OBs and FVGs using `CZoneMerger`.

---

> [!IMPORTANT]
> **Phase 5 (Generic Zone Framework) implementation is complete and saved.**
> As instructed, implementation has stopped here. We await your review & approval before beginning Phase 6.
