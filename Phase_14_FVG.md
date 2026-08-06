# PROJECT SENTINEL: Phase 14 - Fair Value Gap (FVG) Module

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: COMPLETED & VERIFIED (2026-08-06)  

---

## 1. Executive Summary

Phase 14 completes the **Fair Value Gap (FVG) Module** (`CFVGEngine`). It acts as a consumer of framework services, scanning candle sequences to identify price imbalances (Fair Value Gaps) without duplicating any logic or accessing the MT5 API directly.

Strict architectural rules:
- `CFVGEngine` consumes ONLY `SMarketContext`.
- It NEVER accesses the MT5 API directly.
- Extends `SMarketContext` to aggregate `SFVGSnapshot` without breaking any existing interfaces.
- Emits `SFVGSnapshot` and publishes events (`EVENT_MKT_REGIME_CHANGE`) via `CEventBus`.
- Zero trading, order execution, alert, or strategy signals are present.

---

## 2. Folder Tree & New Components

```
Include/SENTINEL/
└── Engines/
    └── FVG/
        ├── FVGTypes.mqh                   # Enums (Directions, Lifecycles), SFairValueGap struct
        ├── IFVGEngine.mqh                 # Public interface for FVG Engine
        ├── FVGSnapshot.mqh                # Immutable SFVGSnapshot model with versioning
        ├── FVGConfiguration.mqh           # CFVGConfiguration settings (min size, partial fill ratio)
        ├── FVGDetector.mqh                # CFVGDetector scanning closed candles for imbalances
        ├── FVGLifecycleManager.mqh        # CFVGLifecycleManager managing retests/partial/full fills
        ├── FVGCache.mqh                   # CFVGCache ring buffer history storage
        ├── FVGValidator.mqh               # CFVGValidator checking gap coordinate sanities
        ├── FVGStatistics.mqh              # CFVGStatistics tracking diagnostics
        ├── FVGEvents.mqh                  # CFVGEvents payload factory
        ├── FVGRepository.mqh              # CFVGRepository gap container
        └── FVGEngine.mqh                  # CFVGEngine master framework coordinator
```

---

## 3. Class Responsibilities Matrix

| Component / Class | Primary Responsibility | Single Responsibility Principle |
| :--- | :--- | :--- |
| **`CFVGEngine`** | Master engine implementing `IEngine` and `IFVGEngine`. | FVG Imbalance Gateway |
| **`CFVGDetector`** | Scans candle high/low patterns to discover gaps. | FVG Discovery |
| **`CFVGLifecycleManager`**| Updates gap lifecycles (Created, Active, Partially Filled, Completely Filled). | Lifecycle Management |
| **`CFVGRepository`** | Repository storing and updating active gaps. | Gap Persistence |
| **`CFVGCache`** | Stores historical snapshots in a pre-allocated ring buffer. | Snapshot Cache |
| **`CFVGValidator`** | Validates gap boundaries. | Validation |
| **`CFVGConfiguration`**| Holds detection sensitivity parameters. | Configuration |
| **`SFairValueGap`** | Structure representing a concrete Fair Value Gap zone. | Data Model |
| **`SFVGSnapshot`** | Immutable snapshot object aggregated directly in `SMarketContext`. | Data Snapshot Model |
| **`CFVGEvents`** | Constructs event payloads for `CEventBus`. | Event Payload Factory |
| **`CFVGStatistics`** | Tracks detections and fill diagnostics. | Telemetry & Performance Stats |

---

## 4. Architectural & Integration Diagrams

### Data Flow Diagram
```
[SMarketContext (Base)] ---> [CFVGEngine]
                                    |
                                    v
                       Scans 3-Candle Sequences
                       Tracks Fill & Touch Progress
                                    |
                 +------------------+------------------+
                 |                                     |
                 v                                     v
     [SFVGSnapshot (Immutable)]                [EventBus Publish]
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
| FairValueGaps: SFVGSnapshot (list of active detected gaps)             |
+------------------------------------------------------------------------+
```

---

## 5. Performance Notes & Memory Strategy

- **Zero Allocation in Process Loop**: Snapshots are updated by value copy in static arrays, eliminating `new` / `delete` dynamic calls inside `OnTick()`.
- **Latency Target**: FVG detection and lifecycle calculations latency $< 0.02$ ms per tick.
- **Access Rule**: Downstream modules query gaps strictly via the unified `SMarketContext.fairValueGaps` Snapshot.

---

## 6. Demonstration & Verification

`Phase14DemoTest.mqh` verifies the entire FVG Module pipeline:
1. Core engines initialized, base context built from tick data.
2. `CFVGEngine` processes the context, discovering the bullish gap.
3. Retest and fill boundaries are tracked dynamically.
4. Emits updated `SMarketContext` and dispatches events.

---

> [!IMPORTANT]
> **Phase 14 (FVG Module) implementation is complete and saved.**
> As instructed, implementation has stopped here. We await your review.
