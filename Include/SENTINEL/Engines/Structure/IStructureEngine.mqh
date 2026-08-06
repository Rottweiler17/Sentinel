//+------------------------------------------------------------------+
//|                                             IStructureEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Data/MarketDataSnapshot.mqh"
#include "StructureSnapshot.mqh"

/// @class IStructureEngine
/// @brief Stable public interface contract for the Market Structure Engine.
class IStructureEngine
{
public:
   virtual ~IStructureEngine() {}
   virtual bool GetSnapshot(SStructureSnapshot &snapshot) const = 0;
   virtual SStructureSnapshot GetSnapshot() const = 0;
   virtual void ProcessStructure(const SMarketDataSnapshot &snapshot) = 0;
   virtual void RegisterSwing(const SSwingPoint &swing) = 0;
};
