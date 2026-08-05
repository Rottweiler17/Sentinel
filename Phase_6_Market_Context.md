# PROJECT SENTINEL: Phase 6 - Market Context Framework

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: COMPLETED & VERIFIED (2026-08-05)  

---

## 1. Executive Summary

Phase 6 introduces the unified **Market Context Framework** (`CContextEngine`). It serves as the single source of truth for the framework's state, aggregating all downstream analysis snapshots (Market, Structure, Liquidity, Zones) into a single unified, immutable `SMarketContext` struct.

Key architectural rules:
- Future engines (Order Blocks, FVGs, DecisionEngine) consume `SMarketContext` directly.
- `SMarketContext` is completely immutable; every tick cycle builds a new context with snapshot versioning lineage.
- Pointers to interface types (`IContextEngine`) are exposed to decouple components.
- Zero trading, indicator, or execution logic is present.

---

## 2. Folder Tree & New Components

```
Include/SENTINEL/
└── Framework/
    └── Context/
        ├── MarketContext.mqh              # SMarketContext struct aggregating all snapshots
        ├── IContextEngine.mqh             # Public interface for Context Engine
        ├── ContextBuilder.mqh             # CContextBuilder fluent constructor
        ├── ContextFactory.mqh             # CContextFactory context instantiation factory
        ├── ContextCache.mqh               # CContextCache storing contexts in CRingBuffer
        ├── ContextValidator.mqh           # CContextValidator verifying context consistency
        ├── ContextStatistics.mqh          # CContextStatistics tracking creation telemetry
        ├── ContextEvents.mqh              # CContextEvents payload factory
        ├── ContextRepository.mqh          # CContextRepository looking up historical contexts
        └── ContextEngine.mqh              # CContextEngine master unified engine
```

---

## 3. Class Responsibilities Matrix

| Component / Class | Primary Responsibility | Single Responsibility Principle |
| :--- | :--- | :--- |
| **`CContextEngine`** | Master context engine implementing `IEngine` and `IContextEngine`. | Unified Context Gateway |
| **`CContextBuilder`** | Assembles the `SMarketContext` using builder pattern. | Context Assembly |
| **`CContextFactory`** | Creates versioned `SMarketContext` instances. | Context Construction |
| **`CContextCache`** | Stores historical context frames using a static `CRingBuffer`. | Context Cache |
| **`CContextRepository`**| Looks up historical contexts by ID or timestamp. | Context Query Repository |
| **`CContextValidator`**| Validates alignment and price sanity across snaps. | Context Consistency |
| **`CContextStatistics`**| Tracks created contexts and validation failures. | Telemetry Stats |
| **`SMarketContext`** | Unified immutable data object representing the framework state. | State Model |
| **`CContextEvents`** | Constructs event payloads for `CEventBus`. | Event Payload Factory |

---

## 4. Architectural & Data Flow Diagrams

### Context Pipeline Flow
```
[MT5 Tick] ---> [DataEngine] ---> [SMarketDataSnapshot] --+
                                                          |
[StructureEngine] --------------> [SStructureSnapshot] ---+---> [CContextEngine]
                                                          |            |
[LiquidityEngine] --------------> [SLiquiditySnapshot] ---+            v
                                                          |     Assembles & Validates Context
[ZoneEngine] -------------------> [SZoneSnapshot] --------+            |
                                                                       v
                                                        [SMarketContext (Immutable)]
                                                                       |
                                                     +-----------------+-----------------+
                                                     |                                   |
                                                     v                                   v
                                        Consumed by Future Engines              [EventBus Publish]
                                        (DecisionEngine, Execution)            (EVENT_SYS_INIT / Update)
```

### Dependency Diagram
```
[CContextEngine] ---> [IContextEngine]
      |
      +---> [CContextBuilder] ---> [CContextFactory]
      |
      +---> [CContextCache] ---> [CRingBuffer<SMarketContext>]
      |
      +---> [CContextValidator]
```

---

## 5. Performance Notes & Memory Strategy

- **Zero Allocation in Processing Loop**: The aggregated snapshots and the main context frame are copied by value inside static ring buffers, eliminating dynamic `new` / `delete` calls inside `OnTick()`.
- **Latency Target**: Context aggregation and validation latency $< 0.02$ ms per tick.
- **Access Rule**: Future engines consume `SMarketContext` only. Individual query calls are restricted to prevent out-of-order state reads.

---

## 6. Demonstration & Verification

`Phase6DemoTest.mqh` verifies the entire Unified Context pipeline:
1. Core engines initialized, listener subscribed to `EVENT_SYS_INIT`.
2. Raw ticks simulate price action, generating `MarketDataSnapshot`.
3. Structure, Liquidity, and Zone snapshots generated.
4. `CContextEngine` builds the unified `SMarketContext`.
5. Emits `SMarketContext` and dispatches event payloads through `CEventBus`.

---

## 7. Future Extension Points

- **OrderBlockEngine & FVGEngine**: Will consume the unified `SMarketContext` to scan price range blocks and gaps.
- **DecisionEngine**: Reads `SMarketContext` trends, zones, and liquidity levels to decide execution setup confluences.

---

> [!IMPORTANT]
> **Phase 6 (Market Context Framework) implementation is complete and saved.**
> As instructed, implementation has stopped here. We await your review & approval before beginning Phase 7.
