class_name BattleAction extends BaseAction

#region Declarations
@export var flats : Array[FlatStatChange]
@export var effects : Array[Effects]
@export var r_cost : FlatStatChange ## Uses [class FlatStatChange] similar to flats, but specifically
## to target Aether, Stamina, and etc.
#endregion
