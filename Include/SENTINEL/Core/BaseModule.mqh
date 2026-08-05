//+------------------------------------------------------------------+
//|                                                   BaseModule.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "Interfaces.mqh"

class CBaseModule : public IModule
{
protected:
   string          m_moduleName;
   bool            m_isModuleInit;
   CConfigEngine  *m_configRef;
   CEventBus      *m_eventBusRef;

public:
   CBaseModule(const string name)
      : m_moduleName(name),
        m_isModuleInit(false),
        m_configRef(NULL),
        m_eventBusRef(NULL)
   {}

   virtual ~CBaseModule() {}

   virtual bool InitModule(CConfigEngine *config, CEventBus *bus) override
   {
      m_configRef   = config;
      m_eventBusRef = bus;
      m_isModuleInit = true;
      return true;
   }

   virtual void ProcessModule() override {}
   virtual void OnEvent(const SSentinelEvent &event) override {}
   virtual string GetModuleName() const override { return m_moduleName; }

   virtual void OnDestroy() override
   {
      m_isModuleInit = false;
      m_configRef    = NULL;
      m_eventBusRef  = NULL;
   }
};
