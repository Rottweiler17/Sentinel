//+------------------------------------------------------------------+
//|                                           MarketStateMachine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "StructureTypes.mqh"

/// @enum ENUM_MARKET_STATE
/// @brief High-level market cycle state machine.
enum ENUM_MARKET_STATE
{
   STATE_UNKNOWN = 0,
   STATE_ACCUMULATION,
   STATE_UPTREND,
   STATE_PULLBACK,
   STATE_CONTINUATION,
   STATE_DISTRIBUTION,
   STATE_DOWNTREND
};

/// @class CMarketStateMachine
/// @brief Evaluates structural state transitions (Accumulation -> Uptrend -> Pullback -> Continuation -> Distribution).
class CMarketStateMachine
{
private:
   ENUM_MARKET_STATE m_currentState;
   ENUM_MARKET_STATE m_previousState;

public:
   CMarketStateMachine()
      : m_currentState(STATE_UNKNOWN), m_previousState(STATE_UNKNOWN)
   {}

   /// @brief Evaluates market state based on trends and structural breaks.
   ENUM_MARKET_STATE EvaluateState(ENUM_TREND_TYPE extTrend, ENUM_TREND_TYPE intTrend, ENUM_BREAK_TYPE lastBreak)
   {
      m_previousState = m_currentState;

      if(extTrend == TREND_BULLISH)
      {
         if(intTrend == TREND_BEARISH)
            m_currentState = STATE_PULLBACK;
         else if(lastBreak == BREAK_BOS_BULLISH)
            m_currentState = STATE_CONTINUATION;
         else
            m_currentState = STATE_UPTREND;
      }
      else if(extTrend == TREND_BEARISH)
      {
         if(intTrend == TREND_BULLISH)
            m_currentState = STATE_PULLBACK;
         else if(lastBreak == BREAK_BOS_BEARISH)
            m_currentState = STATE_CONTINUATION;
         else
            m_currentState = STATE_DOWNTREND;
      }
      else if(extTrend == TREND_NEUTRAL)
      {
         m_currentState = STATE_ACCUMULATION;
      }
      else
      {
         m_currentState = STATE_UNKNOWN;
      }

      return m_currentState;
   }

   ENUM_MARKET_STATE CurrentState()  const { return m_currentState; }
   ENUM_MARKET_STATE PreviousState() const { return m_previousState; }

   string StateToString(ENUM_MARKET_STATE state)
   {
      switch(state)
      {
         case STATE_ACCUMULATION: return "ACCUMULATION";
         case STATE_UPTREND:      return "UPTREND";
         case STATE_PULLBACK:     return "PULLBACK";
         case STATE_CONTINUATION: return "CONTINUATION";
         case STATE_DISTRIBUTION: return "DISTRIBUTION";
         case STATE_DOWNTREND:    return "DOWNTREND";
         default:                 return "UNKNOWN";
      }
   }
};
