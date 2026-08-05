//+------------------------------------------------------------------+
//|                                              StructureEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Core/BaseEngine.mqh"
#include "../../Events/EventBus.mqh"
#include "../../Data/MarketDataSnapshot.mqh"
#include "StructureSnapshot.mqh"
#include "StructureCache.mqh"
#include "SwingDetector.mqh"
#include "ExternalStructureAnalyzer.mqh"
#include "InternalStructureAnalyzer.mqh"
#include "BOSDetector.mqh"
#include "CHOCHDetector.mqh"
#include "StructureStatistics.mqh"
#include "StructureEvents.mqh"

/// @class CStructureEngine
/// @brief Master Market Structure Engine. Single source of truth for swings, BOS, CHOCH, and market trend.
class CStructureEngine : public CBaseEngine, public IEventListener
{
private:
   CSwingDetector              m_swingDetector;
   CExternalStructureAnalyzer  m_externalAnalyzer;
   CInternalStructureAnalyzer  m_internalAnalyzer;
   CBOSDetector                m_bosDetector;
   CCHOCHDetector              m_chochDetector;
   CStructureCache             m_cache;
   CStructureStatistics        m_stats;
   SStructureSnapshot          m_currentSnapshot;

   SSwingPoint                 m_lastMajorHigh;
   SSwingPoint                 m_prevMajorHigh;
   SSwingPoint                 m_lastMajorLow;
   SSwingPoint                 m_prevMajorLow;

public:
   CStructureEngine()
      : CBaseEngine("StructureEngine"), m_swingDetector(5)
   {}

   /// @brief Initializes StructureEngine and subscribes to market events on EventBus.
   virtual bool Initialize(CConfigEngine *config, CEventBus *bus) override
   {
      if(!CBaseEngine::Initialize(config, bus))
         return false;

      int swingLength = (int)config.GetInt("structure.swing_length", 5);
      m_swingDetector.SetSwingLength(swingLength);

      if(m_eventBusRef != NULL)
      {
         m_eventBusRef.Subscribe(EVENT_MKT_TICK, this);
         m_eventBusRef.Subscribe(EVENT_MKT_NEW_BAR, this);
      }

      CLogger::Info(m_engineName, StringFormat("StructureEngine initialized with swing length = %d.", swingLength));
      return true;
   }

   /// @brief Consumes event notifications dispatched from EventBus.
   virtual void OnEvent(const SSentinelEvent &event) override
   {
      if(!m_isEnabled) return;

      if(event.type == EVENT_MKT_TICK || event.type == EVENT_MKT_NEW_BAR)
      {
         // Structure processing triggered
      }
   }

   /// @brief Primary market structure calculation method consuming MarketDataSnapshot.
   /// @param snapshot Immutable market snapshot from DataEngine.
   void ProcessStructure(const SMarketDataSnapshot &snapshot)
   {
      if(!m_isEnabled || snapshot.bid <= 0.0) return;

      // 1. Check for live Break of Structure (BOS)
      if(m_lastMajorHigh.type != SWING_TYPE_NONE && m_lastMajorLow.type != SWING_TYPE_NONE)
      {
         SBOSData bos;
         ENUM_TREND_TYPE currentTrend = m_externalAnalyzer.ExternalTrend();

         if(m_bosDetector.DetectBOS(snapshot.currentCandle, 
                                    (currentTrend == TREND_BULLISH ? m_lastMajorHigh : m_lastMajorLow), 
                                    currentTrend, bos))
         {
            m_cache.AddBOS(bos);
            m_stats.RecordBOS();

            if(m_eventBusRef != NULL)
               m_eventBusRef.Publish(CStructureEvents::CreateBOSEvent(bos));
         }

         // 2. Check for Change of Character (CHOCH)
         SCHOCHData choch;
         if(m_chochDetector.DetectCHOCH(snapshot.currentCandle, 
                                        (currentTrend == TREND_BEARISH ? m_lastMajorHigh : m_lastMajorLow), 
                                        currentTrend, choch))
         {
            m_cache.AddCHOCH(choch);
            m_stats.RecordCHOCH();

            if(m_eventBusRef != NULL)
               m_eventBusRef.Publish(CStructureEvents::CreateCHOCHEvent(choch));
         }
      }

      // 3. Update StructureSnapshot
      UpdateSnapshot(snapshot);
   }

   /// @brief Registers a newly identified swing point.
   void RegisterSwing(const SSwingPoint &swing)
   {
      bool isMajor = CSwingClassifier::IsMajorSwing(swing, m_lastMajorHigh, m_swingDetector.SwingLength());

      if(isMajor)
      {
         if(swing.type == SWING_TYPE_HIGH)
         {
            m_prevMajorHigh = m_lastMajorHigh;
            m_lastMajorHigh = swing;
         }
         else
         {
            m_prevMajorLow = m_lastMajorLow;
            m_lastMajorLow = swing;
         }
         m_cache.AddMajorSwing(swing);

         // Recalculate macro external trend
         m_externalAnalyzer.Update(m_lastMajorHigh, m_prevMajorHigh, m_lastMajorLow, m_prevMajorLow);
      }
      else
      {
         m_cache.AddMinorSwing(swing);
      }

      m_stats.RecordSwing(isMajor);

      if(m_eventBusRef != NULL)
         m_eventBusRef.Publish(CStructureEvents::CreateSwingEvent(swing));
   }

   /// @brief Gets pointer to current immutable StructureSnapshot.
   const SStructureSnapshot* GetSnapshot() const { return &m_currentSnapshot; }

private:
   /// @brief Updates current immutable SStructureSnapshot.
   void UpdateSnapshot(const SMarketDataSnapshot &marketSnap)
   {
      m_currentSnapshot.Reset();
      m_currentSnapshot.externalTrend     = m_externalAnalyzer.ExternalTrend();
      m_currentSnapshot.internalTrend     = m_internalAnalyzer.InternalTrend();
      m_currentSnapshot.latestSwingHigh   = m_lastMajorHigh;
      m_currentSnapshot.latestSwingLow    = m_lastMajorLow;
      m_currentSnapshot.previousSwingHigh = m_prevMajorHigh;
      m_currentSnapshot.previousSwingLow  = m_prevMajorLow;

      m_cache.GetLatestBOS(m_currentSnapshot.latestBOS);
      m_cache.GetLatestCHOCH(m_currentSnapshot.latestCHOCH);

      m_currentSnapshot.structureQuality = m_stats.GetStats().structureQualityScore;
      m_currentSnapshot.timestamp        = marketSnap.time;
      m_currentSnapshot.timeframe        = marketSnap.timeframe;
   }
};
