//+------------------------------------------------------------------+
//|                                SentinelAppReplayController.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

/// @class CSentinelAppReplayController
/// @brief MT5 Strategy Tester visual replay controller supporting bar step inspection.
class CSentinelAppReplayController
{
private:
   bool m_isTesterMode;
   bool m_isPaused;
   int  m_replaySpeedMultiplier;

public:
   CSentinelAppReplayController() : m_isTesterMode(false), m_isPaused(false), m_replaySpeedMultiplier(1) {}

   /// @brief Initializes replay controller state.
   void Initialize()
   {
      m_isTesterMode = (bool)MQLInfoInteger(MQL_TESTER);
      m_isPaused     = false;
      m_replaySpeedMultiplier = 1;
   }

   /// @brief Returns true if executing inside Strategy Tester.
   bool IsTesterMode() const { return m_isTesterMode; }

   /// @brief Sets replay pause state.
   void SetPaused(bool paused) { m_isPaused = paused; }

   /// @brief Returns pause state.
   bool IsPaused() const { return m_isPaused; }

   /// @brief Sets replay speed multiplier (1, 5, 10, 50, 100).
   void SetSpeedMultiplier(int speed)
   {
      if(speed == 1 || speed == 5 || speed == 10 || speed == 50 || speed == 100)
         m_replaySpeedMultiplier = speed;
   }

   /// @brief Gets replay speed multiplier.
   int GetSpeedMultiplier() const { return m_replaySpeedMultiplier; }
};
