//+------------------------------------------------------------------+
//|                                                 ThemeManager.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "VisualizationTypes.mqh"

/// @class CThemeManager
/// @brief Manages color palettes across Dark, Light, High Contrast, and Custom themes.
class CThemeManager
{
public:
   /// @brief Gets SColorPalette for the specified ENUM_VISUALIZATION_THEME.
   static SColorPalette GetPalette(ENUM_VISUALIZATION_THEME theme)
   {
      SColorPalette palette;
      switch(theme)
      {
         case THEME_LIGHT:
            palette.background    = C'245,245,245';
            palette.panelHeader   = C'220,220,220';
            palette.textPrimary   = C'20,20,20';
            palette.textSecondary = C'80,80,80';
            palette.bullish       = C'0,150,80';
            palette.bearish       = C'200,40,40';
            palette.neutral       = C'100,100,100';
            palette.activeZone    = C'0,120,215';
            palette.mitigatedZone = C'160,160,160';
            palette.expiredZone   = C'200,200,200';
            palette.accent        = C'120,60,200';
            palette.grid          = C'210,210,210';
            break;

         case THEME_HIGH_CONTRAST:
            palette.background    = clrBlack;
            palette.panelHeader   = C'40,40,40';
            palette.textPrimary   = clrWhite;
            palette.textSecondary = clrYellow;
            palette.bullish       = clrLime;
            palette.bearish       = clrRed;
            palette.neutral       = clrGray;
            palette.activeZone    = clrCyan;
            palette.mitigatedZone = clrMagenta;
            palette.expiredZone   = clrDarkGray;
            palette.accent        = clrYellow;
            palette.grid          = clrWhite;
            break;

         case THEME_CUSTOM:
         case THEME_DARK:
         default:
            palette.background    = C'18,22,28';
            palette.panelHeader   = C'28,34,44';
            palette.textPrimary   = C'220,225,230';
            palette.textSecondary = C'140,150,165';
            palette.bullish       = C'38,166,154';
            palette.bearish       = C'239,83,80';
            palette.neutral       = C'120,130,140';
            palette.activeZone    = C'41,98,255';
            palette.mitigatedZone = C'90,100,110';
            palette.expiredZone   = C'50,60,70';
            palette.accent        = C'255,179,0';
            palette.grid          = C'32,40,50';
            break;
      }
      return palette;
   }
};
