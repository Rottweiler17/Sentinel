//+------------------------------------------------------------------+
//|                                                   ObjectPool.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "../Core/Defs.mqh"
#include <Arrays/ArrayObj.mqh>

template<typename T>
class CObjectPool
{
private:
   CArrayObj m_availablePool;
   CArrayObj m_activePool;
   int       m_capacity;

public:
   CObjectPool(int capacity = SENTINEL_OBJECT_POOL_SIZE)
      : m_capacity(capacity)
   {
      m_availablePool.FreeMode(true);
      m_activePool.FreeMode(false);

      for(int i = 0; i < m_capacity; i++)
      {
         T *obj = new T();
         m_availablePool.Add(obj);
      }
   }

   ~CObjectPool()
   {
      m_activePool.Clear();
      m_availablePool.Clear();
   }

   T* Acquire()
   {
      int count = m_availablePool.Total();
      if(count <= 0)
      {
         // Pool exhausted, expand dynamically
         T *newObj = new T();
         m_activePool.Add(newObj);
         return newObj;
      }

      T *obj = m_availablePool.Detach(count - 1);
      m_activePool.Add(obj);
      return obj;
   }

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

   int ActiveCount() const { return m_activePool.Total(); }
   int AvailableCount() const { return m_availablePool.Total(); }
};
