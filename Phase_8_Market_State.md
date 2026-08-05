# PROJECT SENTINEL: Phase 8 - Market State Engine

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: COMPLETED & VERIFIED (2026-08-05)  

---

## 1. Executive Summary

Phase 8 completes the **Market State Engine** (`CMarketStateEngine`). It serves as the single source of truth for classifying the current market environment (Bullish/Bearish Trends, Accumulation, Distribution, Pullbacks, Compressions, High/Low Volatility, Liquidity Hunts, and Post-Sweep states) using information already calculated and stored within `SMarketContext`.

Strict architectural rules:
- `CMarketStateEngine` consumes ONLY `SMarketContext`.
- It NEVER accesses the MT5 API directly.
- Extends `SMarketContext` to aggregate `SMarketStateSnapshot` without breaking any existing interfaces.
- Emits `SMarketStateSnapshot` and publishes events (`EVENT_MKT_REGIME_CHANGE`) via `CEventBus`.
- Zero trading, indicator, signal, drawing, or execution logic is present.

---

## 2. Folder Tree & New Components

```
Include/SENTINEL/
└── Engines/
    └── State/
        ├── MarketStateTypes.mqh           # Enums (Environment States, Volatility Ratings)
        ├── IMarketStateEngine.mqh         # Public interface for Market State Engine
        ├── MarketStateSnapshot.mqh        # Immutable SMarketStateSnapshot model with versioning
        ├── MarketStateConfiguration.mqh   # CMarketStateConfiguration threshold parameter settings
        ├── MarketStateAnalyzer.mqh        # CMarketStateAnalyzer computing volatility & trend rating metrics
        ├── MarketStateClassifier.mqh      # CMarketStateClassifier resolving specific states (e.g. Post-Sweep)
        ├── MarketStateCache.mqh           # CMarketStateCache ring buffer history storage
        ├── MarketStateValidator.mqh       # CMarketStateValidator checking state validities
        ├── MarketStateStatistics.mqh      # CMarketStateStatistics tracking evaluations and transition counts
        ├── MarketStateEvents.mqh          # CMarketStateEvents payload factory
        └── MarketStateEngine.mqh          # CMarketStateEngine master coordinator
```

---

## 3. Class Responsibilities Matrix

| Component / Class | Primary Responsibility | Single Responsibility Principle |
| :--- | :--- | :--- |
| **`CMarketStateEngine`** | Master state engine implementing `IEngine` and `IMarketStateEngine`. | State Classification Gateway |
| **`CMarketStateClassifier`**| Evaluates trends, sessions, and sweeps to resolve exact environment classification. | State Classification |
| **`CMarketStateAnalyzer`**| Computes volatility ratings (spread normalized) and trend intensities. | Market State Analysis |
| **`CMarketStateCache`** | Stores historical state snapshots in a pre-allocated ring buffer. | State Snapshot Cache |
| **`CMarketStateValidator`**| Validates state codes. | Validation |
| **`CMarketStateConfiguration`**| Configuration thresholds for volatility and trend strength classification. | Configuration |
| **`SMarketStateSnapshot`** | Immutable snapshot object aggregated directly in `SMarketContext`. | Data Snapshot Model |
| **`CMarketStateEvents`** | Constructs event payloads for `CEventBus`. | Event Payload Factory |
| **`CMarketStateStatistics`**| Tracks evaluations and transition counts. | Telemetry & Performance Stats |

---

## 4. Architectural & Data Flow Diagrams

### State Pipeline Flow
```
[SMarketContext (Base)] ---> [CMarketStateEngine]
                                    |
                                    v
                       Analyzes Volatility & Trend Ratings
                       Classifies Environment State (e.g. Post-Sweep, Range)
                                    |
                 +------------------+------------------+
                 |                                     |
                 v                                     v
 [SMarketStateSnapshot (Immutable)]            [EventBus Publish]
                 |                             (EVENT_MKT_REGIME_CHANGE)
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
+------------------------------------------------------------------------+
```

---

## 5. Performance Notes & Memory Strategy

- **Zero Allocation in Process Loop**: Snapshots and classifications are updated by value copy in static `CRingBuffer` arrays, eliminating `new` / `delete` dynamic calls inside `OnTick()`.
- **Latency Target**: State evaluation and rolling calculations latency $< 0.02$ ms per tick.
- **Access Rule**: Future engines query session details strictly via the unified `SMarketContext.state` Snapshot.

---

## 6. Demonstration & Verification

`Phase8DemoTest.mqh` verifies the entire Market State Engine pipeline:
1. Core engines initialized, base context built from tick data.
2. `CMarketStateEngine` processes the base context, resolving volatility rating and trend ratings.
3. Post-sweep and range states are classified and updated dynamically.
4. Emits updated `SMarketContext` and dispatches state transitions.

---

> [!IMPORTANT]
> **Phase 8 (Market State Engine) implementation is complete and saved.**
> As instructed, implementation has stopped here. We await your review & approval before beginning Phase 9.
