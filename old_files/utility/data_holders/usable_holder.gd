class_name Usable extends Action

#region Declarations
@export var us_id : StringName ## Internal id for name of usable's action
@export var us_name : String ## Name that displays in game 
@export var combat_ok : bool

var linked_slot : InventorySlot
#@export var equippable : bool
#@export var item_material : StringName
#@export var item_modifier : StringName
#@export var equip_slot : StringName
#@export var stackable : bool
#@export var stack_count : int
#endregion
