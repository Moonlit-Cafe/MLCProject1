class_name CombatAction extends Action

enum ResourceType {
	NONE,
	HP,
	STAMINA,
	AETHER
}

@export var ac_cost : AbilityCostPacket = AbilityCostPacket.new() ## The cost of the action
@export var damage_type : Genum.DamageType ## The kind of damage this action takes by default
@export var value : float = 1. ## The raw damage this action puts out
@export var a_range : int = 1 ## The distance an action may be carried.

#region Events
func load_data(data: Dictionary) -> void:
	var dmh := DataManipulationHelper.new()
	var shape_id : String = data.get("shape_id")
	shape = ResourceManager.action_shape_compendium.get(shape_id)
	ac_cost = dmh.detect_special_data(data.get("ac_cost"))
	damage_type = dmh.detect_special_data(data.get("damage_type"))
	value = dmh.detect_special_data(data.get("value"))
	a_range = dmh.detect_special_data(data.get("a_range"))

func save_data() -> Dictionary:
	var dmh := DataManipulationHelper.new()
	var data = {
		"shape_id": shape.shape_id,
		"ac_cost": dmh.encode_special_data(ac_cost),
		"damage_type": dmh.encode_special_data(damage_type),
		"value": dmh.encode_special_data(value),
		"a_range": dmh.encode_special_data(a_range)
	}
	return data

func get_manager_data() -> Dictionary[StringName, Variant]:
	var data : Dictionary[StringName, Variant] = {
		&"id": ac_id,
		&"name": ac_name,
		&"shape_id": shape,
		&"ac_cost": ac_cost,
		&"damage_type": damage_type,
		&"value": value,
		&"a_range": a_range
	}
	return data
#endregion
