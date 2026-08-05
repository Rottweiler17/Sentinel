# PROJECT SENTINEL: Phase 10 - Order Flow Approximation Framework

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: COMPLETED & VERIFIED (2026-08-05)  

---

## 1. Executive Summary

Phase 10 completes the **Order Flow Approximation Framework** (`COrderFlowEngine`). It is responsible for inferring buy/sell execution pressures, initiative, participation scores, and absorption/aggression estimators from available context feed parameters.

Strict architectural rules:
- `COrderFlowEngine` consumes ONLY `SMarketContext`.
- It NEVER accesses the MT5 API directly.
- Extends `SMarketContext` to aggregate `SOrderFlowSnapshot` without breaking any existing interfaces.
- Emits `SOrderFlowSnapshot` and publishes events (`EVENT_MKT_VOLUME_PROFILE`) via `CEventBus`.
- **Disclaimer**: Documented clearly that the values are framework-derived estimates and do not represent true exchange order book depth or transactions.

---

## 2. Folder Tree & New Components

```
Include/SENTINEL/
└── Engines/
    └── OrderFlow/
        ├── OrderFlowTypes.mqh             # Enums (Initiatives, Absorption States)
        ├── IOrderFlowEngine.mqh           # Public interface for Order Flow Engine
        ├── OrderFlowSnapshot.mqh          # Immutable SOrderFlowSnapshot model with versioning
        ├── OrderFlowConfiguration.mqh     # COrderFlowConfiguration parameters
        ├── PressureAnalyzer.mqh           # CPressureAnalyzer estimating buy/sell pressures
        ├── ParticipationAnalyzer.mqh      # CParticipationAnalyzer estimating participation rates
        ├── InitiativeAnalyzer.mqh         # CInitiativeAnalyzer determining buyer/seller aggression
        ├── AbsorptionEstimator.mqh        # CAbsorptionEstimator estimating zone tests absorption
        ├── OrderFlowAnalyzer.mqh          # COrderFlowAnalyzer composite evaluator
        ├── OrderFlowCache.mqh             # COrderFlowCache ring buffer history storage
        ├── OrderFlowValidator.mqh         # COrderFlowValidator validating snapshot sanities
        ├── OrderFlowStatistics.mqh        # COrderFlowStatistics tracking counters
        ├── OrderFlowEvents.mqh            # COrderFlowEvents payload factory
        └── OrderFlowEngine.mqh            # COrderFlowEngine master engine coordinator
```

---

## 3. Class Responsibilities Matrix

| Component / Class | Primary Responsibility | Single Responsibility Principle |
| :--- | :--- | :--- |
| **`COrderFlowEngine`** | Master engine implementing `IEngine` and `IOrderFlowEngine`. | Order Flow Gateway |
| **`COrderFlowAnalyzer`** | Orchestrates all calculations. | Order Flow Analysis |
| **`CPressureAnalyzer`** | Estimates buying and selling pressures based on price spread/volatility. | Pressure Estimations |
| **`CParticipationAnalyzer`**| Approximates participant activity rates. | Participation Analysis |
| **`CInitiativeAnalyzer`** | Classifies active buyer/seller initiative. | Initiative Classification |
| **`CAbsorptionEstimator`**| Estimates absorption behavior near key support/resistance zones. | Absorption Estimations |
| **`COrderFlowCache`** | Stores historical order flow snapshots in a pre-allocated ring buffer. | Snapshot Cache |
| **`COrderFlowValidator`**| Validates snapshot values. | Validation |
| **`COrderFlowConfiguration`**| Configuration aggression/absorption thresholds. | Configuration |
| **`SOrderFlowSnapshot`** | Immutable snapshot object aggregated directly in `SMarketContext`. | Data Snapshot Model |
| **`COrderFlowEvents`** | Constructs event payloads for `CEventBus`. | Event Payload Factory |

---

## 4. Architectural & Data Flow Diagrams

### Pipeline Flow
```
[SMarketContext (Base)] ---> [COrderFlowEngine]
                                    |
                                    v
                       Estimates Buy/Sell Pressures & Initiative
                       Estimates Absorption near Active Zones
                                    |
                 +------------------+------------------+
                 |                                     |
                 v                                     v
   [SOrderFlowSnapshot (Immutable)]            [EventBus Publish]
                 |                             (EVENT_MKT_VOLUME_PROFILE)
                 v
   [SMarketContext (Updated)]
                 |
                 v
     Future Downstream Modules
     (DecisionEngine, Execution)
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
| OrderFlow    : SOrderFlowSnapshot (estimated pressure, initiative, abs)|
+------------------------------------------------------------------------+
```

---

## 5. Performance Notes & Memory Strategy

- **Zero Allocation in Process Loop**: Snapshots are updated by value copy in static `CRingBuffer` arrays, eliminating `new` / `delete` dynamic calls inside `OnTick()`.
- **Latency Target**: Order flow estimation latency $< 0.02$ ms per tick.
- **Access Rule**: Future engines query session details strictly via the unified `SMarketContext.orderFlow` Snapshot.

---

## 6. Demonstration & Verification

`Phase10DemoTest.mqh` verifies the entire Order Flow Approximation Framework pipeline:
1. Core engines initialized, base context built from tick data.
2. `COrderFlowEngine` processes the base context, evaluating estimated pressures and participation metrics.
3. Buyer/seller initiative and absorption parameters are classified and updated dynamically.
4. Emits updated `SMarketContext` and dispatches events.

---

> [!IMPORTANT]
> **Phase 10 (Order Flow Approximation) implementation is complete and saved.**
> As instructed, implementation has stopped here. We await your review & approval before beginning Phase 11.
