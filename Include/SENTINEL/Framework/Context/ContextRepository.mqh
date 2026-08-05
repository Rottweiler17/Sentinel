//+------------------------------------------------------------------+
//|                                           ContextRepository.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "MarketContext.mqh"
#include "ContextCache.mqh"

/// @class CContextRepository
/// @brief Repository providing historical search queries over the context cache.
class CContextRepository
{
private:
   CContextCache *m_cacheRef;

public:
   CContextRepository(CContextCache *cache = NULL) : m_cacheRef(cache) {}

   void SetCache(CContextCache *cache) { m_cacheRef = cache; }

   /// @brief Looks up a context by ID.
   bool FindById(ulong id, SMarketContext &outContext) const
   {
      if(m_cacheRef == NULL) return false;
      int count = m_cacheRef.Size();

      for(int i = 0; i < count; i++)
      {
         SMarketContext context;
         if(m_cacheRef.GetContext(i, context) && context.contextId == id)
         {
            outContext = context;
            return true;
         }
      }
      return false;
   }
};
