//+------------------------------------------------------------------+
//|                                                       Logger.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "LogLevel.mqh"
#include "../Core/Defs.mqh"

class CLogger
{
private:
   static ENUM_LOG_LEVEL s_minLogLevel;
   static string         s_logFileName;
   static bool           s_toFile;
   static bool           s_toTerminal;

public:
   static void Init(ENUM_LOG_LEVEL minLevel = LOG_LEVEL_INFO, bool toTerminal = true, bool toFile = true)
   {
      s_minLogLevel = minLevel;
      s_toTerminal  = toTerminal;
      s_toFile      = toFile;
      s_logFileName = "SENTINEL/logs/Sentinel_" + TimeToString(TimeCurrent(), TIME_DATE) + ".log";
   }

   static void Log(ENUM_LOG_LEVEL level, const string sender, const string message)
   {
      if(level < s_minLogLevel || level == LOG_LEVEL_OFF)
         return;

      string levelStr = LevelToString(level);
      string timeStr  = TimeToString(TimeLocal(), TIME_DATE|TIME_SECONDS);
      string formatted = StringFormat("[%s][%s][%s] %s", timeStr, levelStr, sender, message);

      if(s_toTerminal)
         Print(formatted);

      if(s_toFile)
         WriteToFile(formatted);
   }

   static void Debug(const string sender, const string message) { Log(LOG_LEVEL_DEBUG, sender, message); }
   static void Info(const string sender, const string message)  { Log(LOG_LEVEL_INFO, sender, message); }
   static void Warn(const string sender, const string message)  { Log(LOG_LEVEL_WARN, sender, message); }
   static void Error(const string sender, const string message) { Log(LOG_LEVEL_ERROR, sender, message); }

private:
   static string LevelToString(ENUM_LOG_LEVEL level)
   {
      switch(level)
      {
         case LOG_LEVEL_DEBUG: return "DEBUG";
         case LOG_LEVEL_INFO:  return "INFO";
         case LOG_LEVEL_WARN:  return "WARN";
         case LOG_LEVEL_ERROR: return "ERROR";
         default:              return "UNKNOWN";
      }
   }

   static void WriteToFile(const string text)
   {
      int handle = FileOpen(s_logFileName, FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ, ';');
      if(handle != INVALID_HANDLE)
      {
         FileSeek(handle, 0, SEEK_END);
         FileWriteString(handle, text + "\r\n");
         FileClose(handle);
      }
   }
};

// Initialize static members
ENUM_LOG_LEVEL CLogger::s_minLogLevel = LOG_LEVEL_INFO;
string         CLogger::s_logFileName = "";
bool           CLogger::s_toFile      = false;
bool           CLogger::s_toTerminal  = true;
