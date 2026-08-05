//+------------------------------------------------------------------+
//|                                                   BaseEngine.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "Interfaces.mqh"
#include "../Logging/Logger.mqh"
#include "../Config/ConfigEngine.mqh"

/// @class CBaseEngine
/// @brief Abstract base class for core framework engines supporting dependency injection.
class CBaseEngine : public IEngine
{
protected:
   string          m_engineName;
   bool            m_isEnabled;
   bool            m_isInitialized;
   CConfigEngine  *m_configRef;    ///< Injected configuration repository reference
   CEventBus      *m_eventBusRef;  ///< Injected EventBus dispatcher reference

public:
   /// @brief Constructor accepting engine name identifier.
   CBaseEngine(const string name)
      : m_engineName(name),
        m_isEnabled(true),
        m_isInitialized(false),
        m_configRef(NULL),
        m_eventBusRef(NULL)
   {}

   /// @brief Destructor.
   virtual ~CBaseEngine() {}

   /// @brief Initializes engine with injected configuration and event bus dependencies.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      m_configRef     = config;
      m_eventBusRef   = bus;
      m_isInitialized = true;
      CLogger::Info(m_engineName, "Engine initialized successfully.");
      return true;
   }

   /// @brief Called on every real-time tick.
   virtual void OnTick(const MqlTick &tick) override {}

   /// @brief Called when a new bar closes on a monitored timeframe.
   virtual void OnBar(const string symbol, ENUM_TIMEFRAMES tf) override {}

   /// @brief Gracefully shuts down engine and releases dependency pointers.
   virtual void Shutdown() override
   {
      CLogger::Info(m_engineName, "Engine shutting down.");
      m_isInitialized = false;
      m_configRef     = NULL;
      m_eventBusRef   = NULL;
   }

   /// @brief Returns engine name identifier.
   virtual string GetName() const override { return m_engineName; }

   /// @brief Checks if engine is enabled.
   virtual bool IsEnabled() const override { return m_isEnabled; }

   /// @brief Sets engine enable/disable state.
   virtual void SetEnabled(bool enable) override { m_isEnabled = enable; }
};
