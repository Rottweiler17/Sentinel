//+------------------------------------------------------------------+
//|                                               ContextBuilder.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "MarketContext.mqh"
#include "ContextFactory.mqh"

/// @class CContextBuilder
/// @brief Builder class assembling completed, versioned SMarketContext structures from input snapshots.
class CContextBuilder
{
private:
   SMarketContext m_context;

public:
   CContextBuilder()
   {
      m_context.Reset();
   }

   CContextBuilder* StartNew(ulong id, ulong parentId, ulong seqNum, datetime timeVal)
   {
      m_context = CContextFactory::CreateContext(id, parentId, seqNum, timeVal);
      return &this;
   }

   CContextBuilder* AddMarketData(const SMarketDataSnapshot &marketData)
   {
      m_context.marketData = marketData;
      return &this;
   }

   CContextBuilder* AddStructure(const SStructureSnapshot &structure)
   {
      m_context.structure = structure;
      return &this;
   }

   CContextBuilder* AddLiquidity(const SLiquiditySnapshot &liquidity)
   {
      m_context.liquidity = liquidity;
      return &this;
   }

   CContextBuilder* AddZones(const SZoneSnapshot &zones)
   {
      m_context.zones = zones;
      return &this;
   }

   CContextBuilder* AddSession(const SSessionSnapshot &session)
   {
      m_context.session = session;
      return &this;
   }

   SMarketContext Build()
   {
      return m_context;
   }
};
