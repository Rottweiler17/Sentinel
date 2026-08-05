# PROJECT SENTINEL: Phase 3 - Market Structure Engine

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: COMPLETED & VERIFIED (2026-08-05)  

---

## 1. Executive Summary

Phase 3 builds the institutional-grade **Market Structure Engine** (`CStructureEngine`). It serves as the single source of truth for market structure, swing point identification (Major & Minor), Break of Structure (BOS), Change of Character (CHOCH), and trend classification (Bullish, Bearish, Neutral, Unknown).

Strict decoupling rules are enforced:
- `CStructureEngine` consumes ONLY `SMarketDataSnapshot` objects via `CEventBus`.
- It NEVER queries MT5 API directly.
- It produces an immutable `SStructureSnapshot` and publishes structure events (`EVENT_MKT_SWING_FOUND`, `EVENT_MKT_BOS`, `EVENT_MKT_CHOCH`).
- Zero trading, signal, liquidity, or drawing logic is present.

---

## 2. Folder Tree & New Components

```
Include/SENTINEL/
└── Engines/
    └── Structure/
        ├── StructureTypes.mqh              # ENUM_TREND_TYPE, SBOSData, SCHOCHData, STrendData, SStructureStats
        ├── StructureEvents.mqh             # CStructureEvents payload builder
        ├── StructureSnapshot.mqh           # Immutable SStructureSnapshot data model
        ├── StructureCache.mqh              # CStructureCache using static CRingBuffers
        ├── StructureValidator.mqh          # CStructureValidator for swing & break sanitization
        ├── SwingClassifier.mqh             # CSwingClassifier for Major vs Minor swing categorization
        ├── SwingDetector.mqh               # CSwingDetector for configurable pivot detection
        ├── TrendAnalyzer.mqh               # CTrendAnalyzer for trend & strength evaluation
        ├── InternalStructureAnalyzer.mqh   # CInternalStructureAnalyzer for sub-structure tracking
        ├── ExternalStructureAnalyzer.mqh   # CExternalStructureAnalyzer for macro-structure tracking
        ├── BOSDetector.mqh                 # CBOSDetector for Break of Structure detection
        ├── CHOCHDetector.mqh               # CCHOCHDetector for Change of Character detection
        ├── StructureStatistics.mqh         # CStructureStatistics for quality scoring & telemetry
        └── StructureEngine.mqh             # CStructureEngine master orchestrator engine
```

---

## 3. Class Responsibilities Matrix

| Component / Class | Primary Responsibility | Single Responsibility Principle |
| :--- | :--- | :--- |
| **`CStructureEngine`** | Master orchestrator engine implementing `IEngine` and `IEventListener`. | Market Structure Gateway |
| **`CSwingDetector`** | Configurable pivot high/low detection algorithm (N-bars lookback). | Pivot Detection |
| **`CSwingClassifier`** | Distinguishes Major (External) vs Minor (Internal) swings. | Swing Classification |
| **`CTrendAnalyzer`** | Computes trend direction (Bullish/Bearish/Neutral) and strength. | Trend Direction Analytics |
| **`CInternalStructureAnalyzer`**| Tracks minor swing sequence and sub-structure trends. | Sub-Structure Analytics |
| **`CExternalStructureAnalyzer`**| Tracks major swing sequence and macro structure trends. | Macro-Structure Analytics |
| **`CBOSDetector`** | Detects trend continuation Break of Structure (BOS) events. | BOS Event Detection |
| **`CCHOCHDetector`** | Detects trend reversal Change of Character (CHOCH) events. | CHOCH Event Detection |
| **`CStructureCache`** | $O(1)$ static ring buffer cache storing Swings, BOS, CHOCH, and Trend history. | Structure Data Storage |
| **`CStructureValidator`**| Sanitizes swing prices, timestamp order, and break boundaries. | Validation & Sanitization |
| **`SStructureSnapshot`** | Immutable snapshot object emitted when market structure updates. | Data Snapshot Model |
| **`CStructureEvents`** | Constructs event payloads for EventBus publication. | Event Payload Factory |
| **`CStructureStatistics`** | Tracks swing counts, BOS/CHOCH metrics, and calculates quality score. | Telemetry & Performance Stats |

---

## 4. Architectural & Data Flow Diagrams

### Market Structure Pipeline Flow
```
[MT5 Tick] ---> [DataEngine] ---> [SMarketDataSnapshot] ---> [EventBus] ---> [CStructureEngine]
                                                                                      |
                                                                                      v
                                                                          Processes Swings, BOS, CHOCH
                                                                                      |
                                                                   +------------------+------------------+
                                                                   |                                     |
                                                                   v                                     v
                                                     [SStructureSnapshot (Immutable)]           [EventBus Publish]
                                                                   |                            (EVENT_MKT_BOS,
                                                                   v                             EVENT_MKT_CHOCH,
                                                       Consumed by Future Engines                EVENT_MKT_SWING)
                                                       (Liquidity, OrderBlocks, FVG)
```

### Snapshot Structure Diagram
```
+------------------------------------------------------------------------+
|                          SStructureSnapshot                            |
+------------------------------------------------------------------------+
| Trends            : External Trend, Internal Trend, Trend Strength Score|
| Key Swings        : Latest Major High/Low, Previous Major High/Low     |
| Structural Breaks : Latest SBOSData, Latest SCHOCHData                 |
| Telemetry         : Structure Quality Score, Timestamp, Timeframe      |
+------------------------------------------------------------------------+
```

---

## 5. Performance Notes & Memory Strategy

- **Zero Allocation in Tick Loop**: All swing points, BOS events, CHOCH records, and trend records are stored inside static `CRingBuffer` instances in `CStructureCache`.
- **Latency Target**: Structure processing latency $< 0.05$ ms per tick.
- **MT5 Access Restriction**: `CStructureEngine` does not invoke MT5 API functions (`CopyRates`, `SymbolInfoDouble`). All inputs are derived from `SMarketDataSnapshot`.

---

## 6. Demonstration & Unit Verification

`Phase3DemoTest.mqh` verifies the entire Market Structure pipeline:
1. `CConfigEngine` and `CEventBus` initialized with swing length = 3.
2. `CStructureTestListener` subscribes to `EVENT_MKT_SWING_FOUND`, `EVENT_MKT_BOS`, and `EVENT_MKT_CHOCH`.
3. `CStructureEngine` ingests `SMarketDataSnapshot` and registers swings.
4. Identifies swing pivots, evaluates trend, detects BOS/CHOCH events.
5. Emits `SStructureSnapshot` and publishes event payloads to `CEventBus`.

---

## 7. Future Extension Points

Future engines in Phase 4 and Phase 5 will consume `SStructureSnapshot`:
- **LiquidityEngine**: Uses `latestSwingHigh` and `latestSwingLow` to locate buy-side / sell-side liquidity pools and sweep triggers.
- **ZoneEngine**: Uses BOS points from `latestBOS` to identify Order Block origin candles and Fair Value Gap (FVG) creation windows.
- **DecisionEngine**: Uses `externalTrend`, `internalTrend`, and `structureQuality` score to filter trade setup confluence.

---

> [!IMPORTANT]
> **Phase 3 (Market Structure Engine) implementation is complete and saved.**
> As instructed, implementation has stopped here. We await your review & approval before beginning Phase 4.
