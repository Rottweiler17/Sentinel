//+------------------------------------------------------------------+
//|                                                   RingBuffer.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../Common/Constants.mqh"

/// @class CRingBuffer
/// @brief High-performance, fixed-capacity ring buffer with optional overwrite mode.
/// @tparam T Element type stored in the buffer.
template<typename T>
class CRingBuffer
{
private:
   T      m_buffer[];
   int    m_capacity;
   int    m_head;
   int    m_count;
   bool   m_overwriteMode;

public:
   /// @brief Constructor initializing buffer capacity and overwrite mode.
   CRingBuffer(int capacity = 1000, bool overwriteMode = true)
      : m_capacity(capacity > 0 ? capacity : 1000),
        m_head(0),
        m_count(0),
        m_overwriteMode(overwriteMode)
   {
      ArrayResize(m_buffer, m_capacity);
   }

   /// @brief Destructor releasing buffer storage.
   ~CRingBuffer()
   {
      ArrayFree(m_buffer);
   }

   /// @brief Pushes an item into the buffer.
   /// @param item Item to insert.
   /// @return True if inserted successfully, false if full and overwrite mode is disabled.
   bool Push(const T &item)
   {
      if(m_count >= m_capacity && !m_overwriteMode)
         return false;

      m_buffer[m_head] = item;
      m_head = (m_head + 1) % m_capacity;

      if(m_count < m_capacity)
         m_count++;

      return true;
   }

   /// @brief Retrieves element by index (0 = newest item, Size()-1 = oldest item).
   bool Get(int index, T &outItem) const
   {
      if(index < 0 || index >= m_count)
         return false;

      int actualIndex = (m_head - 1 - index + m_capacity * 2) % m_capacity;
      outItem = m_buffer[actualIndex];
      return true;
   }

   /// @brief Peeks at element by index without modifying buffer state.
   bool Peek(int index, T &outItem) const
   {
      return Get(index, outItem);
   }

   /// @brief Retrieves the newest item in the buffer (index 0).
   bool Back(T &outItem) const
   {
      return Get(0, outItem);
   }

   /// @brief Retrieves the oldest item in the buffer (index Size() - 1).
   bool Front(T &outItem) const
   {
      if(m_count == 0) return false;
      return Get(m_count - 1, outItem);
   }

   /// @brief Checks if the buffer is empty.
   bool IsEmpty() const { return (m_count == 0); }

   /// @brief Checks if the buffer has reached maximum capacity.
   bool IsFull() const { return (m_count >= m_capacity); }

   /// @brief Resizes buffer capacity while preserving existing elements.
   bool Reserve(int newCapacity)
   {
      if(newCapacity <= 0 || newCapacity == m_capacity)
         return false;

      T tempBuffer[];
      ArrayResize(tempBuffer, m_count);

      for(int i = 0; i < m_count; i++)
      {
         Get(i, tempBuffer[i]);
      }

      m_capacity = newCapacity;
      ArrayResize(m_buffer, m_capacity);
      m_head = 0;

      int oldElementsCount = m_count;
      m_count = 0;

      for(int j = oldElementsCount - 1; j >= 0; j--)
      {
         Push(tempBuffer[j]);
      }

      ArrayFree(tempBuffer);
      return true;
   }

   /// @brief Returns the current number of elements stored.
   int Size() const { return m_count; }

   /// @brief Returns the total allocated capacity.
   int Capacity() const { return m_capacity; }

   /// @brief Resets buffer count and pointer to empty state.
   void Clear()
   {
      m_head  = 0;
      m_count = 0;
   }
};
