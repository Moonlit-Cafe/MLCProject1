@abstract
class_name DecisionMaker extends Node

#region Events
@abstract func init(entity: TileEntity) -> void
@abstract func decide_action(actions: ActionArray) -> AIAction
#endregion
