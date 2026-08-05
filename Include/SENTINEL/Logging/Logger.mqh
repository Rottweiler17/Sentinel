//+------------------------------------------------------------------+
//|                                                       Logger.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "LogLevel.mqh"
#include "../Common/Constants.mqh"

/// @class CLogger
/// @brief High-performance static diagnostic logger with persistent file handle and log buffering.
class CLogger
{
private:
   static ENUM_LOG_LEVEL s_minLogLevel;
   static string         s_logFileName;
   static bool           s_toFile;
   static bool           s_toTerminal;
   static int            s_fileHandle;
   static string         s_buffer;
   static int            s_bufferCount;
   static int            s_maxBufferCount;

public:
   /// @brief Initializes logger configuration, opens persistent log file handle.
   static void Init(ENUM_LOG_LEVEL minLevel = LOG_LEVEL_INFO, bool toTerminal = true, bool toFile = true, int bufferLimit = 10)
   {
      s_minLogLevel    = minLevel;
      s_toTerminal     = toTerminal;
      s_toFile         = toFile;
      s_maxBufferCount = (bufferLimit > 0 ? bufferLimit : 10);
      s_bufferCount    = 0;
      s_buffer         = "";

      if(s_toFile && s_fileHandle == INVALID_HANDLE)
      {
         s_logFileName = "SENTINEL/logs/Sentinel_" + TimeToString(TimeCurrent(), TIME_DATE) + ".log";
         s_fileHandle  = FileOpen(s_logFileName, FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ, ';');
         if(s_fileHandle != INVALID_HANDLE)
         {
            FileSeek(s_fileHandle, 0, SEEK_END);
         }
      }
   }

   /// @brief Closes log file handle and flushes remaining log buffer.
   static void Shutdown()
   {
      Flush();
      if(s_fileHandle != INVALID_HANDLE)
      {
         FileClose(s_fileHandle);
         s_fileHandle = INVALID_HANDLE;
      }
   }

   /// @brief Flushes buffered log messages to disk.
   static void Flush()
   {
      if(s_fileHandle != INVALID_HANDLE && StringLen(s_buffer) > 0)
      {
         FileWriteString(s_fileHandle, s_buffer);
         FileFlush(s_fileHandle);
         s_buffer = "";
         s_bufferCount = 0;
      }
   }

   /// @brief Main logging function with severity check and buffer routing.
   static void Log(ENUM_LOG_LEVEL level, const string sender, const string message)
   {
      if(level < s_minLogLevel || level == LOG_LEVEL_OFF)
         return;

      string levelStr = LevelToString(level);
      string timeStr  = TimeToString(TimeLocal(), TIME_DATE|TIME_SECONDS);
      string formatted = StringFormat("[%s][%s][%s] %s\r\n", timeStr, levelStr, sender, message);

      if(s_toTerminal)
         Print(formatted);

      if(s_toFile && s_fileHandle != INVALID_HANDLE)
      {
         s_buffer += formatted;
         s_bufferCount++;

         if(s_bufferCount >= s_maxBufferCount || level == LOG_LEVEL_ERROR)
         {
            Flush();
         }
      }
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
};

// Static Member Initializations
ENUM_LOG_LEVEL CLogger::s_minLogLevel    = LOG_LEVEL_INFO;
string         CLogger::s_logFileName    = "";
bool           CLogger::s_toFile         = false;
bool           CLogger::s_toTerminal     = true;
int            CLogger::s_fileHandle     = INVALID_HANDLE;
string         CLogger::s_buffer         = "";
int            CLogger::s_bufferCount    = 0;
int            CLogger::s_maxBufferCount = 10;
