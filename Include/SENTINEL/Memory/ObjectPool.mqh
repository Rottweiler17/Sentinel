//+------------------------------------------------------------------+
//|                                                   ObjectPool.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "../Common/Constants.mqh"
#include <Arrays/ArrayObj.mqh>

/// @class CObjectPool
/// @brief Generic pre-allocated object recycler supporting chunked growth and usage statistics.
/// @tparam T Class type managed by the pool.
template<typename T>
class CObjectPool
{
private:
   CArrayObj m_availablePool;
   CArrayObj m_activePool;
   int       m_capacity;
   int       m_chunkSize;
   int       m_peakUsage;

public:
   /// @brief Constructor initializing initial pool capacity and expansion chunk size.
   CObjectPool(int initialCapacity = SENTINEL_OBJECT_POOL_SIZE, int chunkSize = SENTINEL_OBJECT_POOL_CHUNK)
      : m_capacity(initialCapacity > 0 ? initialCapacity : 100),
        m_chunkSize(chunkSize > 0 ? chunkSize : 32),
        m_peakUsage(0)
   {
      m_availablePool.FreeMode(true);
      m_activePool.FreeMode(false);

      ExpandPool(m_capacity);
   }

   /// @brief Destructor clearing all pool instances.
   ~CObjectPool()
   {
      m_activePool.Clear();
      m_availablePool.Clear();
   }

   /// @brief Acquires an instance from the available pool. Expands pool in chunks if depleted.
   T* Acquire()
   {
      int available = m_availablePool.Total();
      if(available <= 0)
      {
         ExpandPool(m_chunkSize);
         available = m_availablePool.Total();
      }

      T *obj = m_availablePool.Detach(available - 1);
      m_activePool.Add(obj);

      int currentActive = m_activePool.Total();
      if(currentActive > m_peakUsage)
         m_peakUsage = currentActive;

      return obj;
   }

   /// @brief Releases an active instance back to the available pool.
   bool Release(T *obj)
   {
      if(obj == NULL)
         return false;

      int index = m_activePool.Search(obj);
      if(index >= 0)
      {
         T *detached = m_activePool.Detach(index);
         m_availablePool.Add(detached);
         return true;
      }
      return false;
   }

   /// @brief Releases all active instances back to the available pool.
   void ReleaseAll()
   {
      int total = m_activePool.Total();
      for(int i = total - 1; i >= 0; i--)
      {
         T *obj = m_activePool.Detach(i);
         if(obj != NULL)
            m_availablePool.Add(obj);
      }
   }

   /// @brief Returns the count of currently active in-use instances.
   int ActiveCount() const { return m_activePool.Total(); }

   /// @brief Returns the count of available ready instances in the pool.
   int AvailableCount() const { return m_availablePool.Total(); }

   /// @brief Returns the total allocated capacity (Active + Available).
   int Capacity() const { return m_capacity; }

   /// @brief Returns the maximum number of active objects used simultaneously.
   int PeakUsage() const { return m_peakUsage; }

private:
   /// @brief Expands pool by creating a chunk of new objects.
   void ExpandPool(int count)
   {
      for(int i = 0; i < count; i++)
      {
         T *obj = new T();
         m_availablePool.Add(obj);
      }
      m_capacity += count;
   }
};
