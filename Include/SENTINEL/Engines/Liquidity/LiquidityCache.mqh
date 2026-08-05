//+------------------------------------------------------------------+
//|                                               LiquidityCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "LiquidityTypes.mqh"
#include "../../Memory/RingBuffer.mqh"

/// @class CLiquidityCache
/// @brief Static ring buffer cache storing active liquidity pools, consumed pools, and sweep history.
class CLiquidityCache
{
private:
   CRingBuffer<SLiquidityPool>  m_activePools;
   CRingBuffer<SLiquidityPool>  m_consumedPools;
   CRingBuffer<SLiquiditySweep> m_sweepHistory;

public:
   CLiquidityCache(int capacity = 500)
      : m_activePools(capacity, true),
        m_consumedPools(capacity, true),
        m_sweepHistory(capacity, true)
   {}

   bool AddActivePool(const SLiquidityPool &pool)     { return m_activePools.Push(pool); }
   bool AddConsumedPool(const SLiquidityPool &pool)   { return m_consumedPools.Push(pool); }
   bool AddSweep(const SLiquiditySweep &sweep)         { return m_sweepHistory.Push(sweep); }

   bool GetLatestActivePool(SLiquidityPool &outPool)  const { return m_activePools.Back(outPool); }
   bool GetLatestSweep(SLiquiditySweep &outSweep)      const { return m_sweepHistory.Back(outSweep); }

   /// @brief Searches active pools for nearest Buy-Side Liquidity (BSL) above current price.
   bool FindNearestBSL(double currentPrice, SLiquidityPool &outBSL) const
   {
      double minDiff = 999999.0;
      bool found = false;
      int count = m_activePools.Size();

      for(int i = 0; i < count; i++)
      {
         SLiquidityPool pool;
         if(m_activePools.Get(i, pool) && !pool.isConsumed)
         {
            if(pool.type == LIQUIDITY_TYPE_EQUAL_HIGHS || pool.type == LIQUIDITY_TYPE_BUYSIDE || pool.type == LIQUIDITY_TYPE_SWING_HIGH)
            {
               if(pool.priceLevel > currentPrice)
               {
                  double diff = pool.priceLevel - currentPrice;
                  if(diff < minDiff)
                  {
                     minDiff = diff;
                     outBSL = pool;
                     found = true;
                  }
               }
            }
         }
      }
      return found;
   }

   /// @brief Searches active pools for nearest Sell-Side Liquidity (SSL) below current price.
   bool FindNearestSSL(double currentPrice, SLiquidityPool &outSSL) const
   {
      double minDiff = 999999.0;
      bool found = false;
      int count = m_activePools.Size();

      for(int i = 0; i < count; i++)
      {
         SLiquidityPool pool;
         if(m_activePools.Get(i, pool) && !pool.isConsumed)
         {
            if(pool.type == LIQUIDITY_TYPE_EQUAL_LOWS || pool.type == LIQUIDITY_TYPE_SELLSIDE || pool.type == LIQUIDITY_TYPE_SWING_LOW)
            {
               if(pool.priceLevel < currentPrice)
               {
                  double diff = currentPrice - pool.priceLevel;
                  if(diff < minDiff)
                  {
                     minDiff = diff;
                     outSSL = pool;
                     found = true;
                  }
               }
            }
         }
      }
      return found;
   }

   int ActivePoolsCount()   const { return m_activePools.Size(); }
   int ConsumedPoolsCount() const { return m_consumedPools.Size(); }
   int SweepsCount()        const { return m_sweepHistory.Size(); }

   void Clear()
   {
      m_activePools.Clear();
      m_consumedPools.Clear();
      m_sweepHistory.Clear();
   }
};
