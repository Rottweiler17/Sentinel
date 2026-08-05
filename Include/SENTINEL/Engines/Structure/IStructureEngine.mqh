//+------------------------------------------------------------------+
//|                                             IStructureEngine.mqh |
//|                                                 Project SENTINEL |
//+------------------------------------------------------------------+
#property strict

#include "../../Common/Interfaces.mqh"
#include "../../Data/MarketDataSnapshot.mqh"
#include "StructureSnapshot.mqh"

/// @interface IStructureEngine
/// @brief Stable public interface contract for the Market Structure Engine.
interface IStructureEngine : public IEngine
{
public:
   virtual const SStructureSnapshot* GetSnapshot() const = 0;
   virtual void ProcessStructure(const SMarketDataSnapshot &snapshot) = 0;
   virtual void RegisterSwing(const SSwingPoint &swing) = 0;
};
