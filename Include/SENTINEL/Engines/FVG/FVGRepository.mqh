//+------------------------------------------------------------------+
//|                                                FVGRepository.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "FVGTypes.mqh"

#define FVG_REPO_CAPACITY 100

/// @class CFVGRepository
/// @brief Repository storing, finding, and updating active and filled FVGs.
class CFVGRepository
{
private:
   SFairValueGap m_gaps[FVG_REPO_CAPACITY];
   int           m_count;

public:
   CFVGRepository() : m_count(0)
   {
      Clear();
   }

   void Clear()
   {
      m_count = 0;
      for(int i = 0; i < FVG_REPO_CAPACITY; i++)
      {
         m_gaps[i].id = 0;
         m_gaps[i].upperPrice = 0.0;
         m_gaps[i].lowerPrice = 0.0;
      }
   }

   bool Add(const SFairValueGap &gap)
   {
      if(m_count >= FVG_REPO_CAPACITY) return false;
      m_gaps[m_count] = gap;
      m_count++;
      return true;
   }

   int Count() const { return m_count; }

   bool Get(int index, SFairValueGap &outGap) const
   {
      if(index < 0 || index >= m_count) return false;
      outGap = m_gaps[index];
      return true;
   }

   bool Update(int index, const SFairValueGap &gap)
   {
      if(index < 0 || index >= m_count) return false;
      m_gaps[index] = gap;
      return true;
   }
};
