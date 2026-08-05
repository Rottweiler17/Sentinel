# PROJECT SENTINEL: Phase 4 - Institutional Liquidity Engine & Enhancements

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: APPROVED & COMPLETED (2026-08-05)  

---

## 1. Executive Summary

Phase 4 establishes the **Institutional Liquidity Engine** (`CLiquidityEngine`) as the single source of truth for liquidity pool identification (Equal Highs, Equal Lows, Buy-Side Liquidity, Sell-Side Liquidity), pool strength classification, and liquidity sweep detection (Bullish, Bearish, Partial, Complete).

3 additional architectural enhancements were integrated into the liquidity model:
1. **Liquidity Confidence Scoring**: Added `overallConfidence` (0.0 to 100.0%) and `confidenceSource` (e.g. "Equal Highs + External Swing") to `SLiquiditySnapshot` for decision engine evaluation.
2. **Zone Linkage References**: Added linkage placeholders (`nearestOrderBlockId`, `nearestFVGId`, `nearestSessionHigh`, `nearestSessionLow`) inside `SLiquidityPool` to prepare for Phase 5 zone linking.
3. **Explicit Lifecycle Tracking**: Added `ENUM_LIQUIDITY_LIFECYCLE` (`LIQUIDITY_STATE_CREATED`, `ACTIVE`, `SWEPT`, `CONSUMED`, `EXPIRED`) to track liquidity state transitions.

---

## 2. Directory Structure & Added Components

```
Include/SENTINEL/
└── Engines/
    └── Liquidity/
        ├── LiquidityTypes.mqh                 # Enums (Strength, Type, SweepType, Lifecycle), SLiquidityPool, SLiquiditySweep
        ├── LiquidityEvents.mqh                # CLiquidityEvents payload factory
        ├── LiquiditySnapshot.mqh              # Immutable SLiquiditySnapshot model with versioning & confidence
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

## 3. Verified Architectural Enhancements

| Enhancement | Class / Header | Description | Status |
| :--- | :--- | :--- | :---: |
| **Liquidity Confidence** | [LiquiditySnapshot.mqh](file:///d:/Trading/Project%20Sentinel/Include/SENTINEL/Engines/Liquidity/LiquiditySnapshot.mqh) | `overallConfidence` score and `confidenceSource` breakdown. | COMPLETED |
| **Zone Linkage References** | [LiquidityTypes.mqh](file:///d:/Trading/Project%20Sentinel/Include/SENTINEL/Engines/Liquidity/LiquidityTypes.mqh) | Linkage placeholders (`nearestOrderBlockId`, `nearestFVGId`, `nearestSessionHigh/Low`). | COMPLETED |
| **Lifecycle State Machine** | [LiquidityTypes.mqh](file:///d:/Trading/Project%20Sentinel/Include/SENTINEL/Engines/Liquidity/LiquidityTypes.mqh) | `ENUM_LIQUIDITY_LIFECYCLE` (`CREATED`, `ACTIVE`, `SWEPT`, `CONSUMED`, `EXPIRED`). | COMPLETED |

---

## 4. Verification

`Phase4DemoTest.mqh` verifies:
- End-to-end tick ingestion $\rightarrow$ Market & Structure Snapshots $\rightarrow$ LiquidityEngine $\rightarrow$ EQH / Sweep detection $\rightarrow$ Confidence calculation $\rightarrow$ LiquiditySnapshot creation $\rightarrow$ EventBus publication.

---

> [!IMPORTANT]
> **Phase 4 and all architectural enhancements are approved and completed.**
> We are ready to begin Phase 5 upon your request.
