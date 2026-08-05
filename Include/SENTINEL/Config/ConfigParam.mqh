//+------------------------------------------------------------------+
//|                                                  ConfigParam.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include <Object.mqh>

/// @enum ENUM_PARAM_TYPE
/// @brief Parameter value data types supported by ConfigParam.
enum ENUM_PARAM_TYPE
{
   PARAM_TYPE_INT = 0,
   PARAM_TYPE_DOUBLE,
   PARAM_TYPE_STRING,
   PARAM_TYPE_BOOL
};

/// @class CConfigParam
/// @brief Unified parameter container storing strongly-typed key-value configurations.
class CConfigParam : public CObject
{
private:
   string          m_key;
   ENUM_PARAM_TYPE m_type;
   long            m_valInt;
   double          m_valDouble;
   string          m_valString;
   bool            m_valBool;

public:
   CConfigParam(const string key, long val)   : m_key(key), m_type(PARAM_TYPE_INT),    m_valInt(val), m_valDouble(0.0), m_valBool(false) {}
   CConfigParam(const string key, double val) : m_key(key), m_type(PARAM_TYPE_DOUBLE), m_valInt(0),   m_valDouble(val), m_valBool(false) {}
   CConfigParam(const string key, string val) : m_key(key), m_type(PARAM_TYPE_STRING), m_valInt(0),   m_valDouble(0.0), m_valString(val), m_valBool(false) {}
   CConfigParam(const string key, bool val)   : m_key(key), m_type(PARAM_TYPE_BOOL),   m_valInt(0),   m_valDouble(0.0), m_valBool(val) {}

   string Key() const { return m_key; }
   ENUM_PARAM_TYPE Type() const { return m_type; }

   long   GetInt() const { return m_valInt; }
   double GetDouble() const { return m_valDouble; }
   string GetString() const { return m_valString; }
   bool   GetBool() const { return m_valBool; }
};
