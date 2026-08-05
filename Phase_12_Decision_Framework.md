# PROJECT SENTINEL: Phase 12 - Decision Framework

**Author**: Lead Software Architect  
**Project**: SENTINEL - Professional Trading Analysis Framework for MetaTrader 5 (MQL5)  
**Status**: COMPLETED & VERIFIED (2026-08-06)  

---

## 1. Executive Summary

Phase 12 completes the generic **Decision Framework** (`CDecisionEngine`). It serves as the strategy-independent evaluation engine that aggregates standardized features (Trend, Liquidity, Zones, Sessions, Volume, and Order Flow) to produce overall confluence scores, confidence limits, and generic recommendations (Favorable, Neutral, Unfavorable, High Confluence, Low Confluence).

Strict architectural rules:
- `CDecisionEngine` consumes ONLY `SFeatureSnapshot`.
- It NEVER accesses the MT5 API directly.
- Extends `SMarketContext` to aggregate `SDecisionSnapshot` without breaking any existing interfaces.
- Emits `SDecisionSnapshot` and publishes events (`EVENT_TRD_DECISION_READY`) via `CEventBus`.
- **Disclaimer**: Do NOT output BUY or SELL. Do NOT generate trading signals, entries, executions, or position management.

---

## 2. Folder Tree & New Components

```
Include/SENTINEL/
└── Framework/
    └── Decisions/
        ├── DecisionTypes.mqh              # Enums (Generic Recommendations)
        ├── IDecisionEngine.mqh            # Public interface for Decision Engine
        ├── DecisionSnapshot.mqh           # Immutable SDecisionSnapshot model with versioning
        ├── DecisionConfiguration.mqh      # CDecisionConfiguration score/confluence thresholds
        ├── ScoringEngine.mqh              # CScoringEngine computing component & overall scores
        ├── ConfidenceEngine.mqh           # CConfidenceEngine calculating confidence averages
        ├── ConfluenceEngine.mqh           # CConfluenceEngine calculating scoring variances
        ├── RecommendationEngine.mqh       # CRecommendationEngine deriving generic recommendations
        ├── RuleEngine.mqh                 # CRuleEngine checking guideline logic rules
        ├── DecisionAnalyzer.mqh           # CDecisionAnalyzer composite assessment evaluator
        ├── DecisionCache.mqh              # CDecisionCache ring buffer history storage
        ├── DecisionValidator.mqh          # CDecisionValidator checking score bounds sanities
        ├── DecisionStatistics.mqh         # CDecisionStatistics tracking evaluations
        ├── DecisionEvents.mqh             # CDecisionEvents payload factory
        ├── DecisionRepository.mqh         # CDecisionRepository lookup query container
        └── DecisionEngine.mqh             # CDecisionEngine master coordinator
```

---

## 3. Class Responsibilities Matrix

| Component / Class | Primary Responsibility | Single Responsibility Principle |
| :--- | :--- | :--- |
| **`CDecisionEngine`** | Master engine implementing `IEngine` and `IDecisionEngine`. | Decision Gateway |
| **`CDecisionAnalyzer`** | Orchestrates scoring, confidence, confluence, rules, and recommendation runs. | Assessment Evaluation |
| **`CRuleEngine`** | Checks logic rules and thresholds. | Logic Guidelines |
| **`CScoringEngine`** | Calculates individual score ratings and averages. | Score Calculation |
| **`CConfidenceEngine`** | Calculates confidence levels from features. | Confidence Calculations |
| **`CConfluenceEngine`** | Measures agreement/alignment across all scoring dimensions. | Confluence Variance Calculations |
| **`CRecommendationEngine`**| Derives generic favorability recommendations. | Recommendation Classification |
| **`CDecisionCache`** | Stores historical decision snapshots in a pre-allocated ring buffer. | Snapshot Cache |
| **`CDecisionValidator`**| Validates score bounds. | Validation |
| **`CDecisionConfiguration`**| Holds confluence thresholds and score parameters. | Configuration |
| **`SDecisionSnapshot`** | Immutable snapshot object aggregated directly in `SMarketContext`. | Data Snapshot Model |
| **`CDecisionEvents`** | Constructs event payloads for `CEventBus`. | Event Payload Factory |
| **`CDecisionStatistics`**| Tracks evaluation and outcome metrics. | Telemetry & Performance Stats |

---

## 4. Architectural & Data Flow Diagrams

### Decision Pipeline Flow
```
[SFeatureSnapshot] ---> [CDecisionEngine]
                               |
                               v
                  Verifies Guideline Rule Filters
                  Calculates Scores & Confluences
                  Derives Generic Recommendation (e.g. High Confluence)
                               |
            +------------------+------------------+
            |                                     |
            v                                     v
[SDecisionSnapshot (Immutable)]           [EventBus Publish]
            |                             (EVENT_TRD_DECISION_READY)
            v
[SMarketContext (Updated)]
            |
            v
Future Downstream Modules (Executions)
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
| Features     : SFeatureSnapshot (trend, liquidity, volume features)    |
| Decisions    : SDecisionSnapshot (overallScore, confluence, recommend) |
+------------------------------------------------------------------------+
```

---

## 5. Performance Notes & Memory Strategy

- **Zero Allocation in Process Loop**: Decision snapshots are updated by value copy in static `CRingBuffer` arrays, eliminating `new` / `delete` dynamic calls inside `OnTick()`.
- **Latency Target**: Decision calculations latency $< 0.02$ ms per tick.
- **Access Rule**: Future engines query session details strictly via the unified `SMarketContext.decisions` Snapshot.

---

## 6. Demonstration & Verification

`Phase12DemoTest.mqh` verifies the entire Decision Framework pipeline:
1. Core engines initialized, feature snapshot generated.
2. `CDecisionEngine` processes the features, executing confidence/confluence mappings.
3. Guidelines are filtered, and recommendations derived.
4. Emits updated `SMarketContext` and dispatches decision updated events.

---

> [!IMPORTANT]
> **Phase 12 (Decision Framework) implementation is complete and saved.**
> As instructed, implementation has stopped here. We await your review & approval before beginning the next phase.
