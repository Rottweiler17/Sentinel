//+------------------------------------------------------------------+
//|                                                   Interfaces.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "Defs.mqh"
#include "Types.mqh"
#include <Canvas\Canvas.mqh>

// Forward declarations
class CConfigEngine;
class CEventBus;

//+------------------------------------------------------------------+
//| Interface: IEngine                                              |
//+------------------------------------------------------------------+
interface IEngine
{
   public:
      virtual bool         Initialize(const string configParams) = 0;
      virtual void         OnTick(const MqlTick &tick) = 0;
      virtual void         OnBar(const string symbol, ENUM_TIMEFRAMES tf) = 0;
      virtual void         Shutdown() = 0;
      virtual string       GetName() const = 0;
      virtual bool         IsEnabled() const = 0;
      virtual void         SetEnabled(bool enable) = 0;
};

//+------------------------------------------------------------------+
//| Event Struct & Interface: IEventListener                         |
//+------------------------------------------------------------------+
enum ENUM_SENTINEL_EVENT_TYPE
{
   EVENT_NONE = 0,
   EVENT_TICK,
   EVENT_NEW_BAR,
   EVENT_SWING_FOUND,
   EVENT_BOS,
   EVENT_CHOCH,
   EVENT_ZONE_CREATED,
   EVENT_ZONE_MITIGATED,
   EVENT_LIQUIDITY_SWEEP,
   EVENT_VWAP_UPDATE,
   EVENT_CONFLUENCE_SCORE,
   EVENT_SIGNAL_GENERATED,
   EVENT_ALERT_TRIGGERED
};

struct SSentinelEvent
{
   ENUM_SENTINEL_EVENT_TYPE type;
   datetime                 timestamp;
   string                   symbol;
   ENUM_TIMEFRAMES          timeframe;
   double                   priceValue;
   ulong                    entityId;
   string                   payloadJson;
};

interface IEventListener
{
   public:
      virtual void         OnEvent(const SSentinelEvent &event) = 0;
};

//+------------------------------------------------------------------+
//| Interface: IModule                                              |
//+------------------------------------------------------------------+
interface IModule : public IEventListener
{
   public:
      virtual bool         InitModule(CConfigEngine *config, CEventBus *bus) = 0;
      virtual void         ProcessModule() = 0;
      virtual string       GetModuleName() const = 0;
      virtual void         OnDestroy() = 0;
};

//+------------------------------------------------------------------+
//| Interface: IDrawable                                            |
//+------------------------------------------------------------------+
interface IDrawable
{
   public:
      virtual void         Render(CCanvas &canvas, int chartWidth, int chartHeight) = 0;
      virtual bool         IsDirty() const = 0;
      virtual void         SetDirty(bool dirty) = 0;
};
