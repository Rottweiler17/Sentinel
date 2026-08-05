# PROJECT SENTINEL: Phase 9 - Volume Framework

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: COMPLETED & VERIFIED (2026-08-05)  

---

## 1. Executive Summary

Phase 9 completes the reusable **Volume Framework** (`CVolumeEngine`). It serves as the single source of truth for volume-related tracking (Tick Volume, Real Volume, Relative Volume, Rolling Averages, Volume Trend, Rate of Change, and Session/Daily Volume parameters) collected from the MT5 data stream.

Strict architectural rules:
- `CVolumeEngine` consumes ONLY `SMarketContext`.
- It NEVER accesses the MT5 API directly. It reads raw candle volume feeds from the aggregated snapshots.
- Extends `SMarketContext` to aggregate `SVolumeSnapshot` without breaking any existing interfaces.
- Emits `SVolumeSnapshot` and publishes events (`EVENT_VOLUME_UPDATED`, `EVENT_VOLUME_SPIKE`) via `CEventBus`.
- Zero order flow delta footprint, trading, indicator, signal, or drawing logic is present.

---

## 2. Folder Tree & New Components

```
Include/SENTINEL/
└── Engines/
    └── Volume/
        ├── VolumeTypes.mqh                # Enums (Volume Trends, States)
        ├── IVolumeEngine.mqh              # Public interface for Volume Engine
        ├── VolumeSnapshot.mqh             # Immutable SVolumeSnapshot model with versioning
        ├── VolumeConfiguration.mqh        # CVolumeConfiguration average period & spike multiplier settings
        ├── VolumeCollector.mqh            # CVolumeCollector volume field extractor
        ├── TickVolumeAnalyzer.mqh         # CTickVolumeAnalyzer analyzing spikes and compressions
        ├── RelativeVolumeAnalyzer.mqh     # CRelativeVolumeAnalyzer computing RVol ratio metrics
        ├── VolumeCache.mqh                # CVolumeCache ring buffer history storage
        ├── VolumeValidator.mqh            # CVolumeValidator checking volume sanity
        ├── VolumeStatistics.mqh           # CVolumeStatistics rolling calculations
        ├── VolumeEvents.mqh               # CVolumeEvents payload factory
        └── VolumeEngine.mqh               # CVolumeEngine master volume coordinator
```

---

## 3. Class Responsibilities Matrix

| Component / Class | Primary Responsibility | Single Responsibility Principle |
| :--- | :--- | :--- |
| **`CVolumeEngine`** | Master volume engine implementing `IEngine` and `IVolumeEngine`. | Volume Analysis Gateway |
| **`CVolumeCollector`** | Extracts tick volume and real volume parameters from context snapshots. | Volume Collection |
| **`CTickVolumeAnalyzer`**| Classifies volume expansion, compression, spike, and dry-up states. | Volume State Analysis |
| **`CRelativeVolumeAnalyzer`**| Calculates Relative Volume (RVol) ratios comparing current vs average. | RVol Analytics |
| **`CVolumeCache`** | Stores historical volume snapshots in a pre-allocated ring buffer. | Volume Cache |
| **`CVolumeValidator`** | Sanitizes volume values. | Validation |
| **`CVolumeConfiguration`**| Holds rolling average periods and spike multiplier configurations. | Configuration |
| **`SVolumeSnapshot`** | Immutable snapshot object aggregated directly in `SMarketContext`. | Data Snapshot Model |
| **`CVolumeEvents`** | Constructs event payloads for `CEventBus`. | Event Payload Factory |
| **`CVolumeStatistics`** | Tracks rolling average, session volume, and daily volume metrics. | Rolling Calculations |

---

## 4. Architectural & Data Flow Diagrams

### Volume Pipeline Flow
```
[SMarketContext (Base)] ---> [CVolumeEngine]
                                    |
                                    v
                       Collects & Evaluates Volume Spikes
                       Calculates Relative Volume & Trends
                                    |
                 +------------------+------------------+
                 |                                     |
                 v                                     v
   [SVolumeSnapshot (Immutable)]               [EventBus Publish]
                 |                             (EVENT_MKT_VOLUME_PROFILE)
                 v
   [SMarketContext (Updated)]
                 |
                 v
     Future Downstream Modules
     (OrderBlocks, FVG, DecisionEngine)
```

### Updated MarketContext Diagram
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
+------------------------------------------------------------------------+
```

---

## 5. Performance Notes & Memory Strategy

- **Zero Allocation in Process Loop**: Volume snapshots are updated by value copy in static `CRingBuffer` arrays, eliminating `new` / `delete` dynamic calls inside `OnTick()`.
- **Latency Target**: Volume analysis latency $< 0.02$ ms per tick.
- **Access Rule**: Future engines query volume details strictly via the unified `SMarketContext.volume` Snapshot.

---

## 6. Demonstration & Verification

`Phase9DemoTest.mqh` verifies the entire Volume Framework pipeline:
1. Core engines initialized, base context built from tick data.
2. `CVolumeEngine` processes the base context, evaluating rolling averages and relative volumes.
3. Spikes and compressions are classified and updated dynamically.
4. Emits updated `SMarketContext` and dispatches volume events.

---

> [!IMPORTANT]
> **Phase 9 (Volume Framework) implementation is complete and saved.**
> As instructed, implementation has stopped here. We await your review & approval before beginning Phase 10.
