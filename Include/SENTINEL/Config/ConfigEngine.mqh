//+------------------------------------------------------------------+
//|                                                 ConfigEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ConfigParam.mqh"
#include "../Logging/Logger.mqh"
#include <Arrays/ArrayObj.mqh>

/// @class CConfigEngine
/// @brief Repository for storing, updating, and retrieving hierarchical system parameters.
class CConfigEngine
{
private:
   CArrayObj m_params;

public:
   /// @brief Constructor initializing parameter collection.
   CConfigEngine()
   {
      m_params.FreeMode(true);
   }

   /// @brief Destructor clearing all parameter objects.
   ~CConfigEngine()
   {
      m_params.Clear();
   }

   /// @brief Stores integer parameter.
   void SetInt(const string key, long val) { AddOrReplace(new CConfigParam(key, val)); }

   /// @brief Stores double parameter.
   void SetDouble(const string key, double val) { AddOrReplace(new CConfigParam(key, val)); }

   /// @brief Stores string parameter.
   void SetString(const string key, string val) { AddOrReplace(new CConfigParam(key, val)); }

   /// @brief Stores boolean parameter.
   void SetBool(const string key, bool val) { AddOrReplace(new CConfigParam(key, val)); }

   /// @brief Retrieves integer parameter by key. Returns defaultVal if key is missing.
   long GetInt(const string key, long defaultVal = 0)
   {
      CConfigParam *p = Find(key);
      return (p != NULL) ? p.GetInt() : defaultVal;
   }

   /// @brief Retrieves double parameter by key. Returns defaultVal if key is missing.
   double GetDouble(const string key, double defaultVal = 0.0)
   {
      CConfigParam *p = Find(key);
      return (p != NULL) ? p.GetDouble() : defaultVal;
   }

   /// @brief Retrieves string parameter by key. Returns defaultVal if key is missing.
   string GetString(const string key, string defaultVal = "")
   {
      CConfigParam *p = Find(key);
      return (p != NULL) ? p.GetString() : defaultVal;
   }

   /// @brief Retrieves boolean parameter by key. Returns defaultVal if key is missing.
   bool GetBool(const string key, bool defaultVal = false)
   {
      CConfigParam *p = Find(key);
      return (p != NULL) ? p.GetBool() : defaultVal;
   }

private:
   /// @brief Unified helper inserting new parameter or replacing existing key.
   void AddOrReplace(CConfigParam *param)
   {
      if(param == NULL) return;

      int total = m_params.Total();
      for(int i = 0; i < total; i++)
      {
         CConfigParam *p = m_params.At(i);
         if(p != NULL && p.Key() == param.Key())
         {
            m_params.Delete(i);
            break;
         }
      }
      m_params.Add(param);
   }

   /// @brief Internal search by parameter key string.
   CConfigParam* Find(const string key)
   {
      int total = m_params.Total();
      for(int i = 0; i < total; i++)
      {
         CConfigParam *p = m_params.At(i);
         if(p != NULL && p.Key() == key)
            return p;
      }
      return NULL;
   }
};
