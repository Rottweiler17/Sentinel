//+------------------------------------------------------------------+
//|                                              ConfluenceCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ConfluenceSnapshot.mqh"

#define CONFLUENCE_CACHE_SIZE 64

/// @class CConfluenceCache
/// @brief High-frequency ring buffer cache for ConfluenceSnapshots.
class CConfluenceCache
{
private:
   SConfluenceSnapshot m_buffer[CONFLUENCE_CACHE_SIZE];
   int                 m_head;
   int                 m_count;

public:
   CConfluenceCache() : m_head(0), m_count(0)
   {
      Clear();
   }

   /// @brief Clears cache buffer.
   void Clear()
   {
      m_head  = 0;
      m_count = 0;
      for(int i = 0; i < CONFLUENCE_CACHE_SIZE; i++)
         m_buffer[i].Reset();
   }

   /// @brief Stores snapshot in ring buffer.
   void Push(const SConfluenceSnapshot &snapshot)
   {
      m_buffer[m_head] = snapshot;
      m_head = (m_head + 1) % CONFLUENCE_CACHE_SIZE;
      if(m_count < CONFLUENCE_CACHE_SIZE)
         m_count++;
   }

   /// @brief Gets latest cached snapshot.
   bool GetLatest(SConfluenceSnapshot &outSnapshot) const
   {
      if(m_count == 0)
         return false;

      int latestIdx = (m_head - 1 + CONFLUENCE_CACHE_SIZE) % CONFLUENCE_CACHE_SIZE;
      outSnapshot = m_buffer[latestIdx];
      return true;
   }

   /// @brief Returns cached count.
   int Size() const { return m_count; }
};
