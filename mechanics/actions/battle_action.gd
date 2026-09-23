class_name BattleAction extends BaseAction
##Class that describes an action that can be taken during in-game battle

#region Declarations
@export var flats : Array[FlatStatChange]
@export var effects : Array[Effects]
@export var buffs: Array[Buffs]
@export var r_cost : FlatStatChange ## Uses [class FlatStatChange] similar to flats, but specifically
## to target Aether, Stamina, and etc.
#endregion
