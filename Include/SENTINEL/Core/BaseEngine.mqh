//+------------------------------------------------------------------+
//|                                                   BaseEngine.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "Interfaces.mqh"

class CBaseEngine : public IEngine
{
protected:
   string m_engineName;
   bool   m_isEnabled;
   bool   m_isInitialized;

public:
   CBaseEngine(const string name)
      : m_engineName(name),
        m_isEnabled(true),
        m_isInitialized(false)
   {}

   virtual ~CBaseEngine() {}

   virtual bool Initialize(const string configParams) override
   {
      m_isInitialized = true;
      return true;
   }

   virtual void OnTick(const MqlTick &tick) override {}
   virtual void OnBar(const string symbol, ENUM_TIMEFRAMES tf) override {}

   virtual void Shutdown() override
   {
      m_isInitialized = false;
   }

   virtual string GetName() const override { return m_engineName; }
   virtual bool IsEnabled() const override { return m_isEnabled; }
   virtual void SetEnabled(bool enable) override { m_isEnabled = enable; }
};
