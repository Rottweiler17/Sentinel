//+------------------------------------------------------------------+
//|                                                   BaseModule.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "Interfaces.mqh"
#include "../Logging/Logger.mqh"
#include "../Config/ConfigEngine.mqh"

/// @class CBaseModule
/// @brief Abstract base class for dynamic strategy modules supporting dependency injection.
class CBaseModule : public IModule
{
protected:
   string          m_moduleName;
   bool            m_isModuleInit;
   CConfigEngine  *m_configRef;    ///< Injected configuration repository reference
   CEventBus      *m_eventBusRef;  ///< Injected EventBus dispatcher reference

public:
   /// @brief Constructor accepting module name identifier.
   CBaseModule(const string name)
      : m_moduleName(name),
        m_isModuleInit(false),
        m_configRef(NULL),
        m_eventBusRef(NULL)
   {}

   /// @brief Destructor.
   virtual ~CBaseModule() {}

   /// @brief Initializes module with injected configuration and event bus dependencies.
   virtual bool InitModule(CConfigEngine *config, CEventBus *bus) override
   {
      m_configRef    = config;
      m_eventBusRef  = bus;
      m_isModuleInit = true;
      CLogger::Info(m_moduleName, "Module initialized successfully.");
      return true;
   }

   /// @brief Executes module processing logic.
   virtual void ProcessModule() override {}

   /// @brief Consumes event notification dispatched from CEventBus.
   virtual void OnEvent(const SSentinelEvent &event) override {}

   /// @brief Returns module name identifier.
   virtual string GetModuleName() const override { return m_moduleName; }

   /// @brief Gracefully tears down module and releases dependency pointers.
   virtual void OnDestroy() override
   {
      CLogger::Info(m_moduleName, "Module destroyed.");
      m_isModuleInit = false;
      m_configRef    = NULL;
      m_eventBusRef  = NULL;
   }
};
