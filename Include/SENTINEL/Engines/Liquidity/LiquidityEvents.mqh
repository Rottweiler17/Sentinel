//+------------------------------------------------------------------+
//|                                              LiquidityEvents.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "LiquidityTypes.mqh"

/// @class CLiquidityEvents
/// @brief Helper class constructing standardized liquidity SSentinelEvent payloads for EventBus publication.
class CLiquidityEvents
{
public:
   static SSentinelEvent CreatePoolEvent(const SLiquidityPool &pool)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_ZONE_CREATED;
      event.timestamp  = pool.creationTime;
      event.timeframe  = pool.timeframe;
      event.priceValue = pool.priceLevel;
      event.entityId   = pool.id;
      event.payloadJson= StringFormat("{\"poolType\":%d,\"strength\":%d,\"touches\":%d}", 
                                      pool.type, pool.strength, pool.touchCount);
      return event;
   }

   static SSentinelEvent CreateSweepEvent(const SLiquiditySweep &sweep)
   {
      SSentinelEvent event;
      event.type       = EVENT_MKT_LIQUIDITY_SWEEP;
      event.timestamp  = sweep.sweepTime;
      event.timeframe  = sweep.timeframe;
      event.priceValue = sweep.sweepPrice;
      event.entityId   = sweep.id;
      event.payloadJson= StringFormat("{\"sweepType\":%d,\"poolId\":%d,\"depth\":%.2f,\"strength\":%.2f}", 
                                      sweep.sweepType, sweep.poolId, sweep.penetrationDepth, sweep.sweepStrength);
      return event;
   }
};
