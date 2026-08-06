//+------------------------------------------------------------------+
//|                                                   Interfaces.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "Constants.mqh"
#include "Types.mqh"
#include <Canvas\Canvas.mqh>

// Forward declarations
class CConfigEngine;
class CEventBus;

/// @enum ENUM_SENTINEL_EVENT_TYPE
/// @brief Categorized event types processed across system, market, trading, and UI layers.
enum ENUM_SENTINEL_EVENT_TYPE
{
   EVENT_NONE = 0,

   // --- System Events ---
   EVENT_SYS_INIT,                ///< Framework engine initialization event
   EVENT_SYS_SHUTDOWN,            ///< Framework engine shutdown event
   EVENT_SYS_ERROR,               ///< System diagnostic error event
   EVENT_SYS_CONFIG_CHANGE,       ///< Configuration parameter updated

   // --- Market Events ---
   EVENT_MKT_TICK,                ///< Real-time market tick event
   EVENT_MKT_NEW_BAR,             ///< New bar opened on timeframe
   EVENT_MKT_SWING_FOUND,          ///< Swing High / Swing Low confirmed
   EVENT_MKT_BOS,                 ///< Break of Structure detected
   EVENT_MKT_CHOCH,               ///< Change of Character detected
   EVENT_MKT_ZONE_CREATED,        ///< Order Block / FVG zone created
   EVENT_MKT_ZONE_MITIGATED,      ///< Zone touched or invalidated
   EVENT_MKT_LIQUIDITY_SWEEP,     ///< Buy-side or Sell-side liquidity swept
   EVENT_MKT_VOLUME_PROFILE,      ///< Volume Profile recalculated
   EVENT_MKT_VWAP_UPDATE,         ///< VWAP / Volatility band updated
   EVENT_MKT_DELTA_FLUSH,         ///< Cumulative Volume Delta updated
   EVENT_MKT_ABSORPTION,          ///< Passive volume absorption detected
   EVENT_MKT_SESSION_CHANGE,      ///< Trading session / Killzone state change
   EVENT_MKT_REGIME_CHANGE,       ///< Market regime (trend/range/volatility) update

   // --- Trading Events ---
   EVENT_TRD_CONFLUENCE_SCORE,    ///< Multi-factor confluence score recalculated
   EVENT_TRD_DECISION_READY,      ///< DecisionEngine generated trade evaluation
   EVENT_TRD_SIGNAL_GENERATED,    ///< Setup signal created
   EVENT_TRD_ALERT_TRIGGERED,     ///< User notification triggered
   EVENT_TRD_RISK_CALCULATED,     ///< Position sizing and risk parameters calculated

   // --- UI Events ---
   EVENT_UI_CLICK,                ///< User interface click interaction
   EVENT_UI_TOGGLE_MODULE,        ///< Module enabled/disabled via HUD
   EVENT_UI_THEME_CHANGE          ///< UI color theme changed
};

/// @struct SSentinelEvent
/// @brief Standardized event payload transferred through CEventBus.
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

/// @interface IEventListener
/// @brief Subscriber interface for components consuming events published to CEventBus.
interface IEventListener
{
   public:
      virtual void         OnEvent(const SSentinelEvent &event) = 0;
};

/// @interface IEngine
/// @brief Core lifecycle contract implemented by all domain analytics engines.
interface IEngine : public IEventListener
{
   public:
      virtual bool         Initialize(CConfigEngine *config, CEventBus *bus) = 0;
      virtual void         OnTick(const MqlTick &tick) = 0;
      virtual void         OnBar(const string symbol, ENUM_TIMEFRAMES tf) = 0;
      virtual void         Shutdown() = 0;
      virtual string       GetName() const = 0;
      virtual bool         IsEnabled() const = 0;
      virtual void         SetEnabled(bool enable) = 0;
};

/// @interface IModule
/// @brief Extensible interface implemented by dynamic strategy plugins.
interface IModule : public IEventListener
{
   public:
      virtual bool         InitModule(CConfigEngine *config, CEventBus *bus) = 0;
      virtual void         ProcessModule() = 0;
      virtual string       GetModuleName() const = 0;
      virtual void         OnDestroy() = 0;
};

/// @interface IDrawable
/// @brief Visual rendering interface implemented by chart graphical components.
interface IDrawable
{
   public:
      virtual void         Render(CCanvas &canvas, int chartWidth, int chartHeight) = 0;
      virtual bool         IsDirty() const = 0;
      virtual void         SetDirty(bool dirty) = 0;
};
