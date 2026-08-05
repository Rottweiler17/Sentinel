//+------------------------------------------------------------------+
//|                                               StructureCache.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "StructureTypes.mqh"
#include "../../Memory/RingBuffer.mqh"

/// @class CStructureCache
/// @brief High-speed ring buffer cache for storing swings, BOS, CHOCH, and trend history.
class CStructureCache
{
private:
   CRingBuffer<SSwingPoint> m_majorSwings;
   CRingBuffer<SSwingPoint> m_minorSwings;
   CRingBuffer<SBOSData>     m_bosHistory;
   CRingBuffer<SCHOCHData>   m_chochHistory;
   CRingBuffer<STrendData>   m_trendHistory;

public:
   CStructureCache(int capacity = 500)
      : m_majorSwings(capacity, true),
        m_minorSwings(capacity, true),
        m_bosHistory(capacity, true),
        m_chochHistory(capacity, true),
        m_trendHistory(capacity, true)
   {}

   bool AddMajorSwing(const SSwingPoint &swing) { return m_majorSwings.Push(swing); }
   bool AddMinorSwing(const SSwingPoint &swing) { return m_minorSwings.Push(swing); }
   bool AddBOS(const SBOSData &bos)             { return m_bosHistory.Push(bos); }
   bool AddCHOCH(const SCHOCHData &choch)       { return m_chochHistory.Push(choch); }
   bool AddTrend(const STrendData &trend)       { return m_trendHistory.Push(trend); }

   bool GetLatestMajorSwing(SSwingPoint &outSwing) const { return m_majorSwings.Back(outSwing); }
   bool GetLatestMinorSwing(SSwingPoint &outSwing) const { return m_minorSwings.Back(outSwing); }
   bool GetLatestBOS(SBOSData &outBOS)             const { return m_bosHistory.Back(outBOS); }
   bool GetLatestCHOCH(SCHOCHData &outCHOCH)       const { return m_chochHistory.Back(outCHOCH); }
   bool GetLatestTrend(STrendData &outTrend)       const { return m_trendHistory.Back(outTrend); }

   int MajorSwingsCount() const { return m_majorSwings.Size(); }
   int MinorSwingsCount() const { return m_minorSwings.Size(); }
   int BOSCount()         const { return m_bosHistory.Size(); }
   int CHOCHCount()       const { return m_chochHistory.Size(); }

   void Clear()
   {
      m_majorSwings.Clear();
      m_minorSwings.Clear();
      m_bosHistory.Clear();
      m_chochHistory.Clear();
      m_trendHistory.Clear();
   }
};
