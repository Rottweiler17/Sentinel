# PROJECT: SENTINEL - Professional Trading Analysis Framework

You are a Principal Software Architect, Quantitative Trading Engineer, and Senior MQL5 Developer with 15+ years of experience building institutional-grade trading platforms.

Your task is NOT to immediately write an indicator or EA.

Your task is to architect and build a production-quality trading analysis framework for MetaTrader 5 (MT5) that is modular, scalable, maintainable, and capable of supporting 100+ future trading modules.

This project will eventually include:

• Smart Money Concepts (SMC)
• ICT Concepts
• Liquidity Detection
• Order Flow Approximation
• Volume Analysis
• Market Structure
• Order Blocks
• Fair Value Gaps
• VWAP
• Volume Profile
• Delta Approximation
• Absorption Approximation
• Session Analysis
• AI Probability Engine
• Dashboard
• Trade Journal
• Backtesting
• Automated EA

The framework should NOT depend on any single strategy.

It must be designed like a professional software product.

==================================================

GENERAL REQUIREMENTS

==================================================

Follow:

• SOLID Principles
• Object-Oriented Programming
• Clean Architecture
• DRY
• KISS
• Low Coupling
• High Cohesion
• Separation of Concerns
• Dependency Injection where applicable
• Reusable Components
• High Performance
• Memory Efficient
• Event Driven Design

Never create spaghetti code.

Never put business logic inside drawing code.

Never duplicate logic.

Every engine must have a single responsibility.

==================================================

PROJECT GOAL

==================================================

Build a complete Professional Trading Analysis Framework called

SENTINEL

that can later power

Indicators

Dashboards

Trading Assistants

Expert Advisors

Backtesting Systems

Market Replay

Trade Analytics

without changing the core architecture.

==================================================

IMPORTANT

==================================================

DO NOT BUILD EVERYTHING AT ONCE.

Work milestone by milestone.

After each milestone,

STOP

Wait for my approval.

Only continue after I approve.

==================================================

PHASE 0

PROJECT PLANNING

==================================================

Before writing ANY CODE,

produce a complete software architecture.

Include:

1. Folder Structure

2. Module Structure

3. Engine Responsibilities

4. Class Diagram

5. Data Flow

6. Event Flow

7. Object Lifecycle

8. Rendering Pipeline

9. Tick Processing Pipeline

10. Multi-Timeframe Architecture

11. Configuration System

12. Logging Framework

13. Error Handling

14. Memory Management

15. Performance Strategy

16. Future Plugin System

17. Coding Standards

18. Naming Conventions

19. File Organization

20. Build Order

Do NOT write implementation yet.

==================================================

PHASE 1

FOUNDATION

==================================================

Design the complete folder structure.

Example:

/Core
/Data
/Engines
/Modules
/UI
/Charts
/Drawing
/Utilities
/Config
/Logging
/Events
/Alerts
/Statistics
/Backtesting
/EA
/Resources
/Tests

Explain why every folder exists.

==================================================

PHASE 2

CORE ENGINES

==================================================

Design these engines.

Data Engine

Tick Engine

Volume Engine

Price Engine

Market Structure Engine

Liquidity Engine

Zone Engine

Probability Engine

Signal Engine

Drawing Engine

Alert Engine

Dashboard Engine

Statistics Engine

Configuration Engine

Logging Engine

Module Manager

Every engine must be independent.

==================================================

PHASE 3

PLUGIN SYSTEM

==================================================

Future modules must plug into the framework without changing existing code.

Design a module registration system.

Example:

Liquidity Module

Order Block Module

FVG Module

VWAP Module

Volume Profile Module

Delta Module

Absorption Module

Session Module

Each module should implement a common interface.

==================================================

PHASE 4

EVENT SYSTEM

==================================================

Design an event bus.

Examples:

OnTick

OnNewBar

OnSessionOpen

OnSessionClose

OnSwingDetected

OnLiquidityDetected

OnZoneCreated

OnSignalGenerated

OnAlertTriggered

No engine should directly call another engine.

Everything should communicate using events where appropriate.

==================================================

PHASE 5

DRAWING FRAMEWORK

==================================================

Create a professional chart rendering system.

Support:

Lines

Boxes

Rectangles

Labels

Panels

Buttons

Heatmaps

Dynamic Objects

Theme Manager

Object Pooling

Avoid flickering.

Avoid unnecessary redraws.

==================================================

PHASE 6

CONFIGURATION SYSTEM

==================================================

Every module should expose settings automatically.

No hardcoded values.

Settings should be grouped.

==================================================

PHASE 7

LOGGING

==================================================

Design a logging system.

Support:

Info

Warning

Error

Debug

Performance

==================================================

PHASE 8

PERFORMANCE

==================================================

The framework should comfortably run on multiple MT5 charts simultaneously.

Optimize:

Memory

CPU

Object creation

Tick processing

Rendering

==================================================

OUTPUT FORMAT

==================================================

For every milestone provide:

Overview

Architecture

Reasoning

Folder Structure

Class Structure

Interfaces

Responsibilities

Advantages

Possible Risks

Future Improvements

Then STOP.

Wait for my approval.

Do NOT skip milestones.

Do NOT generate unnecessary code.

Do NOT combine multiple milestones.

Work exactly like a professional software architect building an institutional-grade trading platform.


This is a long-term professional project.

Your responsibility is to act as the Lead Software Architect.

Never rush implementation.

If any architectural decision is unclear, ask me before proceeding.

We will build this exactly like a professional software company.

Start with Phase 0 only.

Do not continue to Phase 1 until I approve.