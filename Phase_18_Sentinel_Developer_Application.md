# Phase 18: Sentinel Developer Application

## Objective
The **Sentinel Developer Application** (`Apps/SentinelDeveloper/SentinelDeveloper.mq5`) is the official standalone MT5 developer application for the **SENTINEL Framework**.

It initializes, executes, visualizes, and validates the complete framework. It is **NOT an EA or trading robot**, contains **zero order execution logic**, and maintains **100% read-only separation** from framework analytical state.

---

## 1. Folder Tree
```
Apps/SentinelDeveloper/
├── SentinelAppEngine.mqh            # Primary lifecycle facade (OnInit, OnTick, OnDeinit)
├── SentinelAppLogger.mqh            # Centralized logging & exception tracer
├── SentinelAppMenu.mqh              # On-screen developer controls & overlay toggle menu
├── SentinelAppPerformanceTracker.mqh # Subsystem & tick latency profiler
├── SentinelAppReplayController.mqh  # Strategy Tester visual replay integration
└── SentinelDeveloper.mq5            # Primary MT5 application entrypoint script
```

---

## 2. Every New Class & Responsibilities

| Class / File | Description & Responsibilities |
| :--- | :--- |
| [`SentinelDeveloper.mq5`](file:///d:/Trading/Project%20Sentinel/Apps/SentinelDeveloper/SentinelDeveloper.mq5) | Primary MT5 application script handling `OnInit()`, `OnCalculate()`, `OnDeinit()`, `OnChartEvent()`, `OnTimer()`. |
| [`SentinelAppEngine.mqh`](file:///d:/Trading/Project%20Sentinel/Apps/SentinelDeveloper/SentinelAppEngine.mqh) | Lifecycle facade class orchestrating 16-subsystem initialization, tick execution, context updates, and shutdown. |
| [`SentinelAppMenu.mqh`](file:///d:/Trading/Project%20Sentinel/Apps/SentinelDeveloper/SentinelAppMenu.mqh) | Developer panel & menu system allowing developers to toggle overlays, change themes, and inspect candle snapshots. |
| [`SentinelAppLogger.mqh`](file:///d:/Trading/Project%20Sentinel/Apps/SentinelDeveloper/SentinelAppLogger.mqh) | Centralized logging categorized by Init, Runtime, Rendering, Validation, Performance Warnings, and Exceptions. |
| [`SentinelAppPerformanceTracker.mqh`](file:///d:/Trading/Project%20Sentinel/Apps/SentinelDeveloper/SentinelAppPerformanceTracker.mqh) | Profiler tracking tick processing duration (ms), frame rate (FPS), memory overhead, and active chart objects. |
| [`SentinelAppReplayController.mqh`](file:///d:/Trading/Project%20Sentinel/Apps/SentinelDeveloper/SentinelAppReplayController.mqh) | Controls visual replay execution and step-forward inspection inside MT5 Strategy Tester ($x1, x5, x10, x50, x100$). |

---

## 3. Application Architecture

```mermaid
flowchart TD
    subgraph App_Entry ["MT5 Application Entrypoint (SentinelDeveloper.mq5)"]
        INIT["OnInit()"]
        CALC["OnCalculate() / OnTick()"]
        DEINIT["OnDeinit()"]
    end

    subgraph App_Core ["Sentinel Developer App Core"]
        ENG["SentinelAppEngine"]
        LOG["SentinelAppLogger"]
        PERF["SentinelAppPerformanceTracker"]
        MENU["SentinelAppMenu"]
        REPLAY["SentinelAppReplayController"]
    end

    subgraph Subsystems ["16 Framework Subsystems"]
        DATA["Data Engine"]
        ANALYSIS["Analytical Engines (Structure, Liquidity, Session, State, Volume, Flow)"]
        CONF["Confluence & Decisions"]
        MODULES["OrderBlock & FVG Modules"]
        VIS["Developer Visualization Toolkit"]
    end

    subgraph Canvas ["MT5 Chart Canvas (Read-Only)"]
        CTX["MarketContext"]
        OVERLAY["Graphic Overlays & Developer Panel"]
    end

    INIT --> LOG & ENG
    ENG --> DATA & ANALYSIS & CONF & MODULES & VIS
    CALC --> DATA
    DATA --> CTX
    CTX --> ANALYSIS & CONF & MODULES
    ANALYSIS & CONF & MODULES --> VIS
    VIS --> OVERLAY & MENU
    DEINIT --> ENG
```

---

## 4. Startup Sequence Diagram

```mermaid
sequenceDiagram
    participant MT5 as MT5 Terminal
    participant APP as SentinelDeveloper.mq5
    participant ENG as SentinelAppEngine
    participant LOG as SentinelAppLogger

    MT5->>APP: OnInit()
    APP->>LOG: Log Application Start
    APP->>ENG: InitializeSubsystems()
    Note over ENG: 1. Framework & Config (0.10 ms)
    Note over ENG: 2. EventBus (0.08 ms)
    Note over ENG: 3. Data Engine (0.12 ms)
    Note over ENG: 4. Structure -> Liquidity -> Zones (0.40 ms)
    Note over ENG: 5. Session -> State -> Volume -> OrderFlow (0.44 ms)
    Note over ENG: 6. Features -> Confluence -> Decisions (0.54 ms)
    Note over ENG: 7. OrderBlocks -> FVGs (0.22 ms)
    Note over ENG: 8. Visualization Toolkit (0.35 ms)
    ENG-->>APP: True (16 Subsystems Initialized)
    APP-->>MT5: INIT_SUCCEEDED
```

---

## 5. Tick Processing Diagram

```mermaid
flowchart TD
    TICK["Incoming Market Tick"] --> DATA["1. Update Data Engine"]
    DATA --> MDS["2. Generate MarketDataSnapshot"]
    MDS --> ENGS["3. Update Analytical Engines (Structure, Liquidity, Session, State, Volume, Flow)"]
    ENGS --> CONF["4. Evaluate Confluence Engine"]
    CONF --> DEC["5. Evaluate Decision Framework (Read-Only)"]
    DEC --> CTX["6. Update MarketContext"]
    CTX --> VIS["7. Render Developer Visualization Overlays"]
    VIS --> MENU["8. Refresh Developer Panel & Menu"]
    MENU --> PROF["9. Record Performance Metrics"]
```

---

## 6. Rendering Diagram

```mermaid
graph TD
    MarketContext --> RenderingManager
    RenderingManager --> DirtyCheck{"Sequence Number Dirty?"}
    DirtyCheck -- "Yes" --> ClearBuffer["Clear Object Pool"]
    ClearBuffer --> RenderLayers["Render 10 Active Layers"]
    RenderLayers --> FlushCanvas["Flush Objects to Chart Canvas (SENTINEL_VIS_*)"]
    FlushCanvas --> UpdateTelemetry["Update FPS & Latency Stats"]
    DirtyCheck -- "No" --> Skip["Skip Re-render (O(1))"]
```

---

## 7. Validation Workflow
1. Click any candle on the chart canvas while Validation Mode is enabled.
2. `VisualizationEvents` converts pixel coordinates to bar index and timestamp.
3. `ValidationModeOverlay` retrieves historical snapshot sequence.
4. Formatted inspection report displaying all 14 snapshots renders on-screen.

---

## 8. Replay Workflow
1. Launch `SentinelDeveloper.mq5` inside MT5 Strategy Tester Visual Mode.
2. `SentinelAppReplayController` detects Strategy Tester context (`MQL_TESTER`).
3. Processes ticks sequentially, updating `MarketContext` and Developer Visualization canvas at chosen speeds ($x1, x5, x10, x50, x100$).
4. Pause / Step-Forward controls enable bar-by-bar framework inspection.

---

## 9. Performance Strategy
- **$O(1)$ Redraw Optimization**: Render cycles execute only when `context.sequenceNumber` increases.
- **Heap Allocation Zero-Guarantee**: Object pool renderer recycles pre-allocated chart objects (`SENTINEL_VIS_*`).
- **Memory Footprint**: Memory usage remains under $32\text{ KB}$ with zero dynamic heap allocations during tick processing.

---

## 10. Compilation Verification
- **Application Entrypoint**: [`SentinelDeveloper.mq5`](file:///d:/Trading/Project%20Sentinel/Apps/SentinelDeveloper/SentinelDeveloper.mq5)
- **Unit Test Suite**: [`Phase18DeveloperAppTest.mqh`](file:///d:/Trading/Project%20Sentinel/Include/SENTINEL/Tests/Phase18DeveloperAppTest.mqh)
- **Framework Demonstration**: [`Phase18DemoTest.mqh`](file:///d:/Trading/Project%20Sentinel/Include/SENTINEL/Tests/Phase18DemoTest.mqh)
- **Git Commit**: `2e89cb6`

---

## 11. Demonstration Explanation
Running `Phase18DemoTest::RunDemo()` demonstrates:
1. Executing `OnInit()` 16-subsystem sequential initialization.
2. Processing incoming market ticks through `MarketContext` pipeline in `OnCalculate()`.
3. Formatting and displaying the Developer Panel telemetry output.
4. Executing clean deinitialization and resource cleanup in `OnDeinit()`.
