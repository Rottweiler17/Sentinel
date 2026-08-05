//+------------------------------------------------------------------+
//|                                                  ConfigParam.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

enum ENUM_PARAM_TYPE
{
   PARAM_TYPE_INT = 0,
   PARAM_TYPE_DOUBLE,
   PARAM_TYPE_STRING,
   PARAM_TYPE_BOOL
};

class CConfigParam
{
private:
   string          m_key;
   ENUM_PARAM_TYPE m_type;
   long            m_valInt;
   double          m_valDouble;
   string          m_valString;
   bool            m_valBool;

public:
   CConfigParam(const string key, long val) : m_key(key), m_type(PARAM_TYPE_INT), m_valInt(val) {}
   CConfigParam(const string key, double val) : m_key(key), m_type(PARAM_TYPE_DOUBLE), m_valDouble(val) {}
   CConfigParam(const string key, string val) : m_key(key), m_type(PARAM_TYPE_STRING), m_valString(val) {}
   CConfigParam(const string key, bool val) : m_key(key), m_type(PARAM_TYPE_BOOL), m_valBool(val) {}

   string Key() const { return m_key; }
   ENUM_PARAM_TYPE Type() const { return m_type; }

   long   GetInt() const { return m_valInt; }
   double GetDouble() const { return m_valDouble; }
   string GetString() const { return m_valString; }
   bool   GetBool() const { return m_valBool; }
};
