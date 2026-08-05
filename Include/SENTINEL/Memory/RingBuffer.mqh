//+------------------------------------------------------------------+
//|                                                   RingBuffer.mqh |
//|                                  Copyright 2026, Project SENTINEL |
//|                                      https://www.sentinel-trade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Project SENTINEL"
#property link      "https://www.sentinel-trade.com"
#property strict

#include "../Core/Defs.mqh"

template<typename T>
class CRingBuffer
{
private:
   T      m_buffer[];
   int    m_capacity;
   int    m_head;
   int    m_count;

public:
   CRingBuffer(int capacity = 1000)
   {
      m_capacity = (capacity > 0) ? capacity : 1000;
      ArrayResize(m_buffer, m_capacity);
      m_head  = 0;
      m_count = 0;
   }

   ~CRingBuffer()
   {
      ArrayFree(m_buffer);
   }

   void Push(const T &item)
   {
      m_buffer[m_head] = item;
      m_head = (m_head + 1) % m_capacity;
      if(m_count < m_capacity)
         m_count++;
   }

   bool Get(int index, T &outItem) const
   {
      if(index < 0 || index >= m_count)
         return false;

      // index 0 is most recent item added
      int actualIndex = (m_head - 1 - index + m_capacity * 2) % m_capacity;
      outItem = m_buffer[actualIndex];
      return true;
   }

   int Size() const { return m_count; }
   int Capacity() const { return m_capacity; }
   void Clear()
   {
      m_head = 0;
      m_count = 0;
   }
};
