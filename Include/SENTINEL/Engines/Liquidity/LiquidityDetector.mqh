//+------------------------------------------------------------------+
//|                                            LiquidityDetector.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "EqualHighDetector.mqh"
#include "EqualLowDetector.mqh"
#include "BuySideLiquidityDetector.mqh"
#include "SellSideLiquidityDetector.mqh"
#include "LiquiditySweepDetector.mqh"

/// @class CLiquidityDetector
/// @brief Master detector encapsulating sub-detectors for EQH, EQL, BSL, SSL, and Sweeps.
class CLiquidityDetector
{
private:
   CEqualHighDetector         m_eqhDetector;
   CEqualLowDetector          m_eqlDetector;
   CBuySideLiquidityDetector  m_bslDetector;
   CSellSideLiquidityDetector m_sslDetector;
   CLiquiditySweepDetector    m_sweepDetector;

public:
   CLiquidityDetector(double tolerancePips = 3.0)
      : m_eqhDetector(tolerancePips), m_eqlDetector(tolerancePips)
   {}

   CEqualHighDetector* EQH() { return &m_eqhDetector; }
   CEqualLowDetector* EQL()  { return &m_eqlDetector; }
   CBuySideLiquidityDetector* BSL() { return &m_bslDetector; }
   CSellSideLiquidityDetector* SSL() { return &m_sslDetector; }
   CLiquiditySweepDetector* Sweep() { return &m_sweepDetector; }
};
