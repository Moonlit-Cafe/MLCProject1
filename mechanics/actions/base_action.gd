class_name BaseAction extends Resource

#region Declarations
@export var name : StringName
@export var description : String
@export var shape : ActionShape
@export var attack_range : int = 1
@export var t_cost := TimeCost.create(Genum.TimeType.TURN, 1)
#endregion
