//+------------------------------------------------------------------+
//|                                         ConfluenceRepository.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "ConfluenceCache.mqh"

/// @class CConfluenceRepository
/// @brief Repository access interface for querying cached ConfluenceSnapshots.
class CConfluenceRepository
{
private:
   CConfluenceCache m_cache;

public:
   /// @brief Stores snapshot into repository cache.
   void Store(const SConfluenceSnapshot &snapshot)
   {
      m_cache.Push(snapshot);
   }

   /// @brief Queries current latest snapshot.
   bool GetLatestSnapshot(SConfluenceSnapshot &outSnapshot) const
   {
      return m_cache.GetLatest(outSnapshot);
   }

   /// @brief Clears storage cache.
   void Clear()
   {
      m_cache.Clear();
   }

   /// @brief Returns total stored snapshot count.
   int Count() const
   {
      return m_cache.Size();
   }
};
