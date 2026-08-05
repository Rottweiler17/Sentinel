//+------------------------------------------------------------------+
//|                                           OrderBlockRepository.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "OrderBlockTypes.mqh"

#define REPO_CAPACITY 100

/// @class COrderBlockRepository
/// @brief Repository storing, finding, and updating active and mitigated order blocks.
class COrderBlockRepository
{
private:
   SOrderBlock m_blocks[REPO_CAPACITY];
   int         m_count;

public:
   COrderBlockRepository() : m_count(0)
   {
      Clear();
   }

   void Clear()
   {
      m_count = 0;
      for(int i = 0; i < REPO_CAPACITY; i++)
      {
         m_blocks[i].id = 0;
         m_blocks[i].upperPrice = 0.0;
         m_blocks[i].lowerPrice = 0.0;
      }
   }

   bool Add(const SOrderBlock &block)
   {
      if(m_count >= REPO_CAPACITY) return false;
      m_blocks[m_count] = block;
      m_count++;
      return true;
   }

   int Count() const { return m_count; }

   bool Get(int index, SOrderBlock &outBlock) const
   {
      if(index < 0 || index >= m_count) return false;
      outBlock = m_blocks[index];
      return true;
   }

   bool Update(int index, const SOrderBlock &block)
   {
      if(index < 0 || index >= m_count) return false;
      m_blocks[index] = block;
      return true;
   }
};
