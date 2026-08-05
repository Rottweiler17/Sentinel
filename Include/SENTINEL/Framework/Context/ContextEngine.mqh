//+------------------------------------------------------------------+
//|                                                ContextEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/BaseEngine.mqh"
#include "../../Events/EventBus.mqh"
#include "IContextEngine.mqh"
#include "ContextBuilder.mqh"
#include "ContextCache.mqh"
#include "ContextValidator.mqh"
#include "ContextStatistics.mqh"
#include "ContextEvents.mqh"

/// @class CContextEngine
/// @brief Master Context Engine. Aggregates all analytics snapshots into a unified, immutable MarketContext.
class CContextEngine : public CBaseEngine, public IContextEngine
{
private:
   CContextBuilder    m_builder;
   CContextCache      m_cache;
   CContextStatistics m_stats;
   SMarketContext     m_currentContext;

   ulong              m_contextSequence;
   ulong              m_lastContextId;

public:
   CContextEngine()
      : CBaseEngine("ContextEngine"),
        m_contextSequence(0),
        m_lastContextId(0)
   {
      m_currentContext.Reset();
   }

   /// @brief Initializes ContextEngine.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      CLogger::Info(m_engineName, "ContextEngine initialized successfully.");
      return true;
   }

   /// @brief Primary pipeline updating and publishing unified SMarketContext.
   virtual void UpdateContext(const SMarketDataSnapshot &marketSnap,
                              const SStructureSnapshot &structSnap,
                              const SLiquiditySnapshot &liqSnap,
                              const SZoneSnapshot &zoneSnap,
                              const SSessionSnapshot &sessionSnap) override
   {
      if(!m_isEnabled) return;

      m_contextSequence++;
      ulong newContextId = (ulong)marketSnap.time_msc + m_contextSequence;

      // Assemble unified immutable context
      m_currentContext = m_builder.StartNew(newContextId, m_lastContextId, m_contextSequence, marketSnap.time)
                           .AddMarketData(marketSnap)
                           .AddStructure(structSnap)
                           .AddLiquidity(liqSnap)
                           .AddZones(zoneSnap)
                           .AddSession(sessionSnap)
                           .Build();

      // Validate context consistency
      if(CContextValidator::IsValidContext(m_currentContext))
      {
         m_cache.AddContext(m_currentContext);
         m_stats.RecordCreated();

         if(m_eventBusRef != NULL)
            m_eventBusRef.Publish(CContextEvents::CreateCreatedEvent(m_currentContext));
      }
      else
      {
         m_stats.RecordValidationFailure();
      }

      m_lastContextId = newContextId;
   }

   virtual const SMarketContext* GetContext() const override { return &m_currentContext; }

   CContextCache* Cache() { return &m_cache; }
};
