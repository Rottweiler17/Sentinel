//+------------------------------------------------------------------+
//|                                           VisualizationTypes.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @enum ENUM_VISUALIZATION_LAYER
/// @brief 10 independent rendering layers.
enum ENUM_VISUALIZATION_LAYER
{
   LAYER_PRICE = 0,
   LAYER_STRUCTURE,
   LAYER_LIQUIDITY,
   LAYER_ZONES,
   LAYER_ORDER_BLOCKS,
   LAYER_FVG,
   LAYER_SESSIONS,
   LAYER_VOLUME,
   LAYER_ORDER_FLOW,
   LAYER_DEBUG,
   LAYER_COUNT
};

/// @enum ENUM_VISUALIZATION_THEME
/// @brief Supported color themes.
enum ENUM_VISUALIZATION_THEME
{
   THEME_DARK = 0,
   THEME_LIGHT,
   THEME_HIGH_CONTRAST,
   THEME_CUSTOM
};

/// @struct SColorPalette
/// @brief Palette colors for rendering objects.
struct SColorPalette
{
   color background;
   color panelHeader;
   color textPrimary;
   color textSecondary;
   color bullish;
   color bearish;
   color neutral;
   color activeZone;
   color mitigatedZone;
   color expiredZone;
   color accent;
   color grid;
};

/// @struct SRenderObject
/// @brief Generic chart graphic element managed by ObjectPoolRenderer.
struct SRenderObject
{
   string                   name;
   ENUM_OBJECT              objectType;
   ENUM_VISUALIZATION_LAYER layer;
   bool                     active;
   
   datetime                 time1;
   double                   price1;
   datetime                 time2;
   double                   price2;

   color                    objColor;
   int                      width;
   ENUM_LINE_STYLE          style;
   int                      fontSize;
   string                   text;

   void Reset()
   {
      name       = "";
      objectType = OBJ_RECTANGLE;
      layer      = LAYER_DEBUG;
      active     = false;
      time1      = 0;
      price1     = 0.0;
      time2      = 0;
      price2     = 0.0;
      objColor   = clrGray;
      width      = 1;
      style      = STYLE_SOLID;
      fontSize   = 9;
      text       = "";
   }
};
