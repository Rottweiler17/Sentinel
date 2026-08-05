# PROJECT SENTINEL: Phase 4 - Institutional Liquidity Engine

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: COMPLETED & VERIFIED (2026-08-05)  

---

## 1. Executive Summary

Phase 4 completes the **Institutional Liquidity Engine** (`CLiquidityEngine`). It serves as the single source of truth for all liquidity pool identification (Equal Highs, Equal Lows, Buy-Side Liquidity, Sell-Side Liquidity), pool strength classification, and liquidity sweep detection (Bullish, Bearish, Partial, Complete).

Strict architectural rules enforced:
- `CLiquidityEngine` is purely objective and generic (no ICT/SMC hardcoded strategy bias).
- It consumes ONLY `SMarketDataSnapshot` and `SStructureSnapshot`.
- It NEVER accesses MT5 API directly.
- It produces an immutable `SLiquiditySnapshot` and dispatches events (`EVENT_MKT_ZONE_CREATED`, `EVENT_MKT_LIQUIDITY_SWEEP`) through `CEventBus`.
- Zero trading, entry/exit, order block, FVG, or drawing logic is present.

---

## 2. Folder Tree & New Components

```
Include/SENTINEL/
└── Engines/
    └── Liquidity/
        ├── LiquidityTypes.mqh                 # Enums (Strength, Type, SweepType) & SLiquidityPool, SLiquiditySweep
        ├── LiquidityEvents.mqh                # CLiquidityEvents payload factory
        ├── LiquiditySnapshot.mqh              # Immutable SLiquiditySnapshot model with versioning
        ├── LiquidityCache.mqh                 # CLiquidityCache ring buffer storage for pools & sweeps
        ├── LiquidityValidator.mqh             # CLiquidityValidator sanitizing pools and sweeps
        ├── LiquidityClassifier.mqh            # CLiquidityClassifier evaluating strength (WEAK to INSTITUTIONAL)
        ├── EqualHighDetector.mqh              # CEqualHighDetector detecting EQH within tolerance
        ├── EqualLowDetector.mqh               # CEqualLowDetector detecting EQL within tolerance
        ├── BuySideLiquidityDetector.mqh       # CBuySideLiquidityDetector detecting BSL above swing highs
        ├── SellSideLiquidityDetector.mqh      # CSellSideLiquidityDetector detecting SSL below swing lows
        ├── LiquiditySweepDetector.mqh         # CLiquiditySweepDetector detecting Bullish/Bearish sweeps
        ├── LiquidityStrengthAnalyzer.mqh      # CLiquidityStrengthAnalyzer computing quality scores
        ├── LiquidityDetector.mqh              # CLiquidityDetector master detector combining sub-detectors
        ├── LiquidityStatistics.mqh            # CLiquidityStatistics tracking sweep count and quality score
        └── LiquidityEngine.mqh                # CLiquidityEngine master orchestrator
```

---

## 3. Class Responsibilities Matrix

| Component / Class | Primary Responsibility | Single Responsibility Principle |
| :--- | :--- | :--- |
| **`CLiquidityEngine`** | Master orchestrator engine implementing `IEngine` and `IEventListener`. | Liquidity Gateway |
| **`CLiquidityDetector`** | Encapsulates sub-detectors for EQH, EQL, BSL, SSL, and Sweeps. | Combined Liquidity Detection |
| **`CEqualHighDetector`** | Detects Equal Highs (EQH) resting buy-side liquidity pools. | EQH Detection |
| **`CEqualLowDetector`** | Detects Equal Lows (EQL) resting sell-side liquidity pools. | EQL Detection |
| **`CBuySideLiquidityDetector`**| Identifies Buy-Side Liquidity (BSL) above swing highs. | BSL Identification |
| **`CSellSideLiquidityDetector`**| Identifies Sell-Side Liquidity (SSL) below swing lows. | SSL Identification |
| **`CLiquiditySweepDetector`**| Detects Bullish, Bearish, Partial, Complete, and False sweeps. | Sweep Detection |
| **`CLiquidityClassifier`** | Classifies pool strength (WEAK to INSTITUTIONAL) based on touches/volume. | Strength Classification |
| **`CLiquidityCache`** | $O(1)$ ring buffer storage for active pools, consumed pools, and sweeps. | Data Cache |
| **`CLiquidityValidator`** | Sanitizes price levels, bounds, and timestamp validity. | Sanitization & Validation |
| **`SLiquiditySnapshot`** | Immutable snapshot object emitted when liquidity state updates. | Data Snapshot Model |
| **`CLiquidityEvents`** | Constructs event payloads for EventBus publication. | Event Payload Factory |
| **`CLiquidityStatistics`** | Tracks active pool count, swept count, and calculates quality score. | Telemetry & Performance Stats |

---

## 4. Architectural & Data Flow Diagrams

### Liquidity Pipeline Flow
```
[MT5 Tick] ---> [DataEngine] ---> [SMarketDataSnapshot] --+
                                                          |
                                                          +---> [CLiquidityEngine]
                                                          |            |
[StructureEngine] --------------> [SStructureSnapshot] -+            v
                                                          Processes EQH, EQL, BSL, SSL & Sweeps
                                                                       |
                                                   +-------------------+-------------------+
                                                   |                                       |
                                                   v                                       v
                                     [SLiquiditySnapshot (Immutable)]            [EventBus Publish]
                                                   |                             (EVENT_MKT_ZONE_CREATED,
                                                   v                              EVENT_MKT_LIQUIDITY_SWEEP)
                                      Consumed by Future Engines
                                      (OrderBlocks, FVG, DecisionEngine)
```

### Snapshot Structure Diagram
```
+-----------------------------------------------------------------------------+
|                             SLiquiditySnapshot                              |
+-----------------------------------------------------------------------------+
| Versioning        : snapshotId, parentId, sequenceNumber                    |
| Nearest Pools     : Nearest BSL (above price), Nearest SSL (below price)   |
| Key Structure     : Latest EQH Pool, Latest EQL Pool                        |
| Sweep State       : Latest SLiquiditySweep, sweepDirection, sweepStrength  |
| Telemetry         : activePoolsCount, sweptPoolsCount, liquidityQualityScore|
+-----------------------------------------------------------------------------+
```

---

## 5. Performance Notes & Memory Strategy

- **Zero Dynamic Allocations in Tick Loop**: Active liquidity pools, consumed pools, and sweep history records operate on static `CRingBuffer` instances in `CLiquidityCache`.
- **Latency Target**: Liquidity evaluation latency $< 0.05$ ms per tick.
- **MT5 API Restriction**: `CLiquidityEngine` never invokes MT5 API functions. Inputs are derived from `SMarketDataSnapshot` and `SStructureSnapshot`.

---

## 6. Demonstration & Unit Verification

`Phase4DemoTest.mqh` verifies the entire Liquidity Engine pipeline:
1. Infrastructure initialized with 3.0 pip tolerance.
2. Listener subscribes to `EVENT_MKT_ZONE_CREATED` and `EVENT_MKT_LIQUIDITY_SWEEP`.
3. Highs are registered in `CStructureEngine` to simulate Equal Highs (EQH).
4. `CLiquidityEngine` ingests market and structure snapshots, detects EQH BSL pools and wick sweeps.
5. Emits `SLiquiditySnapshot` and dispatches event payloads through `CEventBus`.

---

## 7. Future Extension Points

Future engines in Phase 5 will consume `SLiquiditySnapshot`:
- **ZoneEngine (Order Blocks & FVG)**: Uses `latestSweep` events to confirm valid Order Block formation (Order Blocks formed by candles sweeping liquidity before BOS).
- **DecisionEngine**: Evaluates price proximity to `nearestBSL` and `nearestSSL` to calculate target reward-to-risk and execution confluence.

---

> [!IMPORTANT]
> **Phase 4 (Institutional Liquidity Engine) implementation is complete and saved.**
> As instructed, implementation has stopped here. We await your review & approval before beginning Phase 5.
