//+------------------------------------------------------------------+
//|                                     ICTValidationRepository.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ICTValidationSnapshot.mqh"

#define ICT_REPOSITORY_SIZE 64

/// @class CICTValidationRepository
/// @brief Ring-buffer repository storing historical ICTValidationSnapshots.
class CICTValidationRepository
{
private:
   SICTValidationSnapshot m_buffer[ICT_REPOSITORY_SIZE];
   int                    m_head;
   int                    m_count;

public:
   CICTValidationRepository() : m_head(0), m_count(0)
   {
      Clear();
   }

   /// @brief Clears storage cache.
   void Clear()
   {
      m_head  = 0;
      m_count = 0;
      for(int i = 0; i < ICT_REPOSITORY_SIZE; i++)
         m_buffer[i].Reset();
   }

   /// @brief Stores snapshot into ring buffer.
   void Store(const SICTValidationSnapshot &snapshot)
   {
      m_buffer[m_head] = snapshot;
      m_head = (m_head + 1) % ICT_REPOSITORY_SIZE;
      if(m_count < ICT_REPOSITORY_SIZE)
         m_count++;
   }

   /// @brief Gets latest snapshot.
   bool GetLatestSnapshot(SICTValidationSnapshot &outSnapshot) const
   {
      if(m_count == 0)
         return false;

      int latestIdx = (m_head - 1 + ICT_REPOSITORY_SIZE) % ICT_REPOSITORY_SIZE;
      outSnapshot = m_buffer[latestIdx];
      return true;
   }

   /// @brief Returns stored snapshot count.
   int Count() const { return m_count; }
};
