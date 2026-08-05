# PROJECT SENTINEL: Phase 0 - Complete Software Architecture Specification (Approved with Mandatory Changes)

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: APPROVED WITH MANDATORY CHANGES (Updated 2026-08-05)  

---

## Executive Overview

Project **SENTINEL** is an institutional-grade, event-driven, modular quantitative analysis framework designed for MetaTrader 5 (MQL5). It is engineered to support **100+ future trading modules** (Smart Money Concepts, ICT, Volume Profile, Order Flow, Delta, VWAP, Decision Engine, Dashboard, EA, Backtesting) on a single high-performance engine without structural refactoring.

All engines are completely decoupled and reusable without modification across **Indicators, Expert Advisors, Dashboards, Backtesting, and Market Replay**.

---

## 1. Updated Architectural Changes Incorporated

1. **`DecisionEngine`**: Renamed from `ProbabilityEngine`. Combines confluence scoring, market regime filtering, confidence evaluation, execution recommendations, and decision logic.
2. **Volume Engines Decomposition**: `VolumeEngine` split into 5 specialized single-responsibility engines:
   - `VolumeEngine`: Raw volume metrics, tick vs real volume tracking.
   - `VWAPEngine`: Anchored & rolling VWAP calculation and standard deviation volatility bands.
   - `VolumeProfileEngine`: High-Volume Nodes (HVN), Low-Volume Nodes (LVN), Point of Control (POC), Value Area High/Low (VAH/VAL).
   - `DeltaEngine`: Cumulative Delta Volume (CVD), buyer vs. seller volume imbalance.
   - `AbsorptionEngine`: Institutional volume absorption and passive liquidity barrier detection.
3. **`SessionEngine`**: Tracks Asian, London, and NY sessions, Kill Zones, Opening Range, Previous Day High/Low (PDH/PDL), Previous Week High/Low (PWH/PWL), and Previous Month High/Low (PMH/PML).
4. **`MarketRegimeEngine`**: Classifies market state (Trending, Ranging, Expansion, Compression, High/Low Volatility) to gate signal generation across all modules.
5. **`RiskEngine`**: Calculates position sizing, risk percentage, Stop Loss, Take Profit, Break Even, Trailing Stop, Partial Close, and R-Multiple analytics.
6. **`StatisticsEngine` Independence**: Performs all calculation of performance metrics, drawdown, latency, and win-rates independently; `DashboardEngine` strictly acts as a view controller.
7. **Cross-Environment Reusability**: Unified interface contracts allow all engines to run unchanged in Indicators, EAs, Dashboards, Backtesting scripts, and Replay engines.
8. **Future-Proof Plugin Architecture**: Dynamic registration via `CModuleManager` ensures new strategy modules register seamlessly without touching any core engine.

---

## 2. Updated Directory Structure

```
Include/SENTINEL/
├── Core/           # Universal definitions, base structs, macros, base engine classes, and interfaces.
├── Events/         # Event Bus dispatcher, subscriber registry, and event data structures.
├── Config/         # Hierarchical configuration repository and parameter containers.
├── Logging/        # Diagnostic logging framework (Console & File output streams).
├── Memory/         # Memory managers, CObjectPool templates, and CRingBuffer structures.
├── Data/           # DataEngine & TickEngine managing multi-timeframe price series & real-time tick delta.
├── Engines/        # Specialized domain analytical engines:
│   ├── BaseEngine.mqh
│   ├── PriceEngine.mqh
│   ├── StructureEngine.mqh
│   ├── LiquidityEngine.mqh
│   ├── ZoneEngine.mqh
│   ├── VolumeEngine.mqh
│   ├── VWAPEngine.mqh
│   ├── VolumeProfileEngine.mqh
│   ├── DeltaEngine.mqh
│   ├── AbsorptionEngine.mqh
│   ├── SessionEngine.mqh
│   ├── MarketRegimeEngine.mqh
│   ├── RiskEngine.mqh
│   ├── DecisionEngine.mqh
│   ├── SignalEngine.mqh
│   ├── AlertEngine.mqh
│   └── StatisticsEngine.mqh
├── Modules/        # Dynamic strategy plugins (SMC, ICT, Volume Profile, Session, Order Flow).
├── UI/             # Dashboard HUD controls, interactive panels, tables, and buttons.
├── Drawing/        # Render pipeline (CCanvas double buffering, ThemeManager, ObjectPooler).
├── Alerts/         # Multi-channel notification routing (Popups, Push, Webhooks).
├── Statistics/     # System telemetry, tick processing latency, and memory profiling.
├── Backtesting/    # Tick replay simulator and historical strategy backtester bridge.
├── EA/             # Execution layer, risk management, and order management engine.
├── Resources/      # Icons, images, sound files, fonts, and preset JSON templates.
├── Tests/          # Automated test harness for unit/integration testing.
└── Utilities/      # Pure mathematical, time-formatting, and array helper functions.

Indicators/SENTINEL/
└── SENTINEL_Master.mq5 # Primary MT5 indicator host script.
```

---

## 3. Core Engine Responsibilities Table

| Engine | Primary Responsibility | Reusability Scope |
| :--- | :--- | :--- |
| **`CConfigEngine`** | Stores, updates, and validates system runtime parameters. | Universal |
| **`CLogger`** | Traces system operation across configurable severity levels. | Universal |
| **`CDataEngine`** | Fetches and syncs multi-timeframe bar data without main thread blocking. | Universal |
| **`CTickEngine`** | Captures real-time tick stream and tick delta calculation. | Universal |
| **`CPriceEngine`** | Volatility (ATR), range extremes, premium/discount calculation. | Universal |
| **`CStructureEngine`**| Detects swing points, Break of Structure (BOS), and Change of Character (CHoCH).| Universal |
| **`CLiquidityEngine`**| Identifies equal highs/lows, trendline liquidity, and sweep events. | Universal |
| **`CZoneEngine`** | Identifies, tracks, and manages mitigation state of Order Blocks, FVGs, and S/D zones. | Universal |
| **`CVolumeEngine`** | Raw volume tracking (Tick vs Real Volume analysis). | Universal |
| **`CVWAPEngine`** | Anchored/Rolling VWAP and standard deviation volatility bands. | Universal |
| **`CVolumeProfileEngine`**| High-Volume Nodes (HVN), Low-Volume Nodes (LVN), Value Area (VAH/VAL/POC).| Universal |
| **`CDeltaEngine`** | Cumulative Volume Delta (CVD) & order flow buyer/seller imbalance. | Universal |
| **`CAbsorptionEngine`**| Passive liquidity barrier and volume absorption cluster detection. | Universal |
| **`CSessionEngine`** | Asian/London/NY sessions, Kill Zones, Opening Range, PDH/PDL, PWH/PWL, PMH/PML.| Universal |
| **`CMarketRegimeEngine`**| Classifies market state (Trending, Ranging, Expansion, Compression, Volatility).| Universal |
| **`CRiskEngine`** | Position sizing, Risk %, SL/TP, Break Even, Trailing Stop, R-Multiple. | Universal (EA / Indicator) |
| **`CDecisionEngine`** | Evaluates multi-factor confluence scoring & quantitative execution decision logic.| Universal |
| **`CSignalEngine`** | Generates actionable buy/sell setup signals based on decisions. | Universal |
| **`CAlertEngine`** | Dispatches notifications to Terminal popups, Mobile Push, Webhooks. | Universal |
| **`CStatisticsEngine`**| Performs independent calculations of win rate, drawdown, latency, telemetry. | Universal |
| **`CDrawingEngine`** | Manages double-buffered CCanvas overlays & MT5 object pool recycling. | Indicator / HUD |
| **`CModuleManager`** | Dynamic loading, execution order, and teardown of modules. | Universal |

---

## 4. Phased Milestone Roadmap

- **Phase 0**: Architecture Blueprint (COMPLETED & APPROVED WITH CHANGES)
- **Phase 1**: Foundation Framework (`Core/`, `Config/`, `Logging/`, `Memory/`, `Utilities/`, Interfaces, Base Classes, RingBuffer, ObjectPool, Logger, ConfigManager) (CURRENT STEP)
- **Phase 2**: Event Bus & Data Core
- **Phase 3**: Core Analysis Engines
- **Phase 4**: Rendering & UI Framework
- **Phase 5**: Dynamic Plugin Framework & Signals
- **Phase 6**: Dashboard HUD & Master Integration

---

> [!IMPORTANT]
> **Phase 0 is updated and approved with all 8 mandatory changes.**
> Phase 1 Foundation implementation is now active.
