//+------------------------------------------------------------------+
//|                                           ChartObjectManager.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "VisualizationTypes.mqh"

#define VIS_OBJECT_PREFIX "SENTINEL_VIS_"

/// @class CChartObjectManager
/// @brief Low-level chart object manipulation wrapper managing objects prefixed with SENTINEL_VIS_.
class CChartObjectManager
{
public:
   /// @brief Generates standardized object name with SENTINEL_VIS_ prefix.
   static string FormatObjectName(ENUM_VISUALIZATION_LAYER layer, int index, string tag)
   {
      return StringFormat("%sL%d_%s_%d", VIS_OBJECT_PREFIX, (int)layer, tag, index);
   }

   /// @brief Creates or updates a chart object.
   static bool RenderObject(long chartId, const SRenderObject &obj)
   {
      if(!obj.active || obj.name == "")
         return false;

      // If object doesn't exist on chart, create it
      if(ObjectFind(chartId, obj.name) < 0)
      {
         if(!ObjectCreate(chartId, obj.name, obj.objectType, 0, obj.time1, obj.price1, obj.time2, obj.price2))
            return false;
      }
      else
      {
         // Move existing object
         ObjectMove(chartId, obj.name, 0, obj.time1, obj.price1);
         if(obj.time2 > 0 || obj.price2 > 0.0)
            ObjectMove(chartId, obj.name, 1, obj.time2, obj.price2);
      }

      // Update styling properties
      ObjectSetInteger(chartId, obj.name, OBJPROP_COLOR, obj.objColor);
      ObjectSetInteger(chartId, obj.name, OBJPROP_WIDTH, obj.width);
      ObjectSetInteger(chartId, obj.name, OBJPROP_STYLE, obj.style);
      ObjectSetInteger(chartId, obj.name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(chartId, obj.name, OBJPROP_HIDDEN, false);

      if(obj.text != "")
         ObjectSetString(chartId, obj.name, OBJPROP_TEXT, obj.text);

      return true;
   }

   /// @brief Removes object from chart.
   static void DeleteObject(long chartId, const string &name)
   {
      if(ObjectFind(chartId, name) >= 0)
         ObjectDelete(chartId, name);
   }

   /// @brief Purges all SENTINEL_VIS_ objects from chart.
   static void PurgeAll(long chartId)
   {
      int total = ObjectsTotal(chartId, 0, -1);
      for(int i = total - 1; i >= 0; i--)
      {
         string name = ObjectName(chartId, i, 0, -1);
         if(StringFind(name, VIS_OBJECT_PREFIX) == 0)
            ObjectDelete(chartId, name);
      }
   }
};
