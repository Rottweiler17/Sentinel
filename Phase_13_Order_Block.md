# PROJECT SENTINEL: Phase 13 - Order Block Module

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: COMPLETED & VERIFIED (2026-08-06)  

---

## 1. Executive Summary

Phase 13 completes the **Order Block Module** (`COrderBlockEngine`). It acts as a consumer of framework services, scanning market structure swings, volumes, and context configurations to identify supply/demand zones (Order Blocks) without duplicating any logic or accessing the MT5 API directly.

Strict architectural rules:
- `COrderBlockEngine` consumes ONLY `SMarketContext`.
- It NEVER accesses the MT5 API directly.
- Extends `SMarketContext` to aggregate `SOrderBlockSnapshot` without breaking any existing interfaces.
- Emits `SOrderBlockSnapshot` and publishes events (`EVENT_MKT_REGIME_CHANGE`) via `CEventBus`.
- Zero trading, order execution, alert, or strategy signals are present.

---

## 2. Folder Tree & New Components

```
Include/SENTINEL/
└── Engines/
    └── OrderBlock/
        ├── OrderBlockTypes.mqh            # Enums (Directions, Lifecycles), SOrderBlock struct
        ├── IOrderBlockEngine.mqh          # Public interface for Order Block Engine
        ├── OrderBlockSnapshot.mqh         # Immutable SOrderBlockSnapshot model with versioning
        ├── OrderBlockConfiguration.mqh    # COrderBlockConfiguration settings (min strength, limits)
        ├── OrderBlockDetector.mqh         # COrderBlockDetector scanning swings & BOS events
        ├── OrderBlockLifecycleManager.mqh # COrderBlockLifecycleManager managing retests/mitigations
        ├── OrderBlockCache.mqh            # COrderBlockCache ring buffer history storage
        ├── OrderBlockValidator.mqh        # COrderBlockValidator checking block coordinate sanities
        ├── OrderBlockStatistics.mqh       # COrderBlockStatistics tracking diagnostics
        ├── OrderBlockEvents.mqh           # COrderBlockEvents payload factory
        ├── OrderBlockRepository.mqh       # COrderBlockRepository block container
        └── OrderBlockEngine.mqh           # COrderBlockEngine master framework coordinator
```

---

## 3. Class Responsibilities Matrix

| Component / Class | Primary Responsibility | Single Responsibility Principle |
| :--- | :--- | :--- |
| **`COrderBlockEngine`** | Master engine implementing `IEngine` and `IOrderBlockEngine`. | Order Block Gateway |
| **`COrderBlockDetector`** | Scans context swings and volumes to discover block candidates. | OB Discovery |
| **`COrderBlockLifecycleManager`**| Updates block lifecycles (Created, Active, Retested, Mitigated, Expired). | Lifecycle Management |
| **`COrderBlockRepository`**| Repository storing and updating active blocks. | Block Persistence |
| **`COrderBlockCache`** | Stores historical snapshots in a pre-allocated ring buffer. | Snapshot Cache |
| **`COrderBlockValidator`**| Validates block boundaries. | Validation |
| **`COrderBlockConfiguration`**| Holds detection strength parameters. | Configuration |
| **`SOrderBlock`** | Structure representing a concrete order block zone. | Data Model |
| **`SOrderBlockSnapshot`** | Immutable snapshot object aggregated directly in `SMarketContext`. | Data Snapshot Model |
| **`COrderBlockEvents`** | Constructs event payloads for `CEventBus`. | Event Payload Factory |
| **`COrderBlockStatistics`**| Tracks detections and mitigation count diagnostics. | Telemetry & Performance Stats |

---

## 4. Architectural & Integration Diagrams

### Data Flow Diagram
```
[SMarketContext (Base)] ---> [COrderBlockEngine]
                                    |
                                    v
                       Scans Swings & BOS Triggers
                       Tracks Mitigation & Retests
                                    |
                 +------------------+------------------+
                 |                                     |
                 v                                     v
   [SOrderBlockSnapshot (Immutable)]           [EventBus Publish]
                 |                             (EVENT_MKT_REGIME_CHANGE)
                 v
   [SMarketContext (Updated)]
                 |
                 v
     Future Downstream Modules
     (Execution Engine, ML Scoring)
```

### Integration Diagram
```
+------------------------------------------------------------------------+
|                             SMarketContext                             |
+------------------------------------------------------------------------+
| Versioning   : contextId, parentId, sequenceNumber, timestamp          |
| Market Data  : SMarketDataSnapshot (bid, ask, spread, current candle)  |
| Structure    : SStructureSnapshot (swings, trend direction, strength)  |
| Liquidity    : SLiquiditySnapshot (nearest BSL/SSL, active pools, sweep)|
| Zones        : SZoneSnapshot (nearest support/resistance, active zones)|
| Session      : SSessionSnapshot (currentSession, sessionStats, levels) |
| State        : SMarketStateSnapshot (currentState, volatility, strength)|
| Volume       : SVolumeSnapshot (current volume, rolling average, RVol) |
| OrderFlow    : SOrderFlowSnapshot (estimated pressure, initiative, abs)|
| Features     : SFeatureSnapshot (trend, liquidity, volume features)    |
| Decisions    : SDecisionSnapshot (overallScore, confluence, recommend) |
| OrderBlocks  : SOrderBlockSnapshot (list of active detected blocks)    |
+------------------------------------------------------------------------+
```

---

## 5. Performance Notes & Memory Strategy

- **Zero Allocation in Process Loop**: Snapshots are updated by value copy in static arrays, eliminating `new` / `delete` dynamic calls inside `OnTick()`.
- **Latency Target**: Order Block detection and lifecycle calculations latency $< 0.02$ ms per tick.
- **Access Rule**: Downstream modules query blocks strictly via the unified `SMarketContext.orderBlocks` Snapshot.

---

## 6. Demonstration & Verification

`Phase13DemoTest.mqh` verifies the entire Order Block Module pipeline:
1. Core engines initialized, base context built from tick data.
2. `COrderBlockEngine` processes the context, discovering the bullish demand zone.
3. Retest and mitigation boundaries are tracked dynamically.
4. Emits updated `SMarketContext` and dispatches events.

---

> [!IMPORTANT]
> **Phase 13 (Order Block Module) implementation is complete and saved.**
> As instructed, implementation has stopped here. We await your review.
