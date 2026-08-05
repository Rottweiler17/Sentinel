//+------------------------------------------------------------------+
//|                                                 ConfigEngine.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "ConfigParam.mqh"
#include "../Logging/Logger.mqh"
#include <Arrays/ArrayObj.mqh>

class CConfigEngine
{
private:
   CArrayObj m_params;

public:
   CConfigEngine()
   {
      m_params.FreeMode(true);
   }

   ~CConfigEngine()
   {
      m_params.Clear();
   }

   void SetInt(const string key, long val)
   {
      RemoveKey(key);
      m_params.Add(new CConfigParam(key, val));
   }

   void SetDouble(const string key, double val)
   {
      RemoveKey(key);
      m_params.Add(new CConfigParam(key, val));
   }

   void SetString(const string key, string val)
   {
      RemoveKey(key);
      m_params.Add(new CConfigParam(key, val));
   }

   void SetBool(const string key, bool val)
   {
      RemoveKey(key);
      m_params.Add(new CConfigParam(key, val));
   }

   long GetInt(const string key, long defaultVal = 0)
   {
      CConfigParam *p = Find(key);
      return (p != NULL) ? p.GetInt() : defaultVal;
   }

   double GetDouble(const string key, double defaultVal = 0.0)
   {
      CConfigParam *p = Find(key);
      return (p != NULL) ? p.GetDouble() : defaultVal;
   }

   string GetString(const string key, string defaultVal = "")
   {
      CConfigParam *p = Find(key);
      return (p != NULL) ? p.GetString() : defaultVal;
   }

   bool GetBool(const string key, bool defaultVal = false)
   {
      CConfigParam *p = Find(key);
      return (p != NULL) ? p.GetBool() : defaultVal;
   }

private:
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

   void RemoveKey(const string key)
   {
      int total = m_params.Total();
      for(int i = 0; i < total; i++)
      {
         CConfigParam *p = m_params.At(i);
         if(p != NULL && p.Key() == key)
         {
            m_params.Delete(i);
            return;
         }
      }
   }
};
