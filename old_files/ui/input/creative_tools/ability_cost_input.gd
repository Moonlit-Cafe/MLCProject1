class_name AbilityCostInput extends HBoxContainer

#region Declarations
@export var enum_selector : EnumSelectorButton
@export var value_box : SpinBox
#endregion

#region Events
func set_data(keys: Array, enum_value: int, value: int) -> void:
	enum_selector.init(keys, enum_value)
	value_box.value = value

func get_data() -> AbilityCostPacket:
	var new_packet := AbilityCostPacket.new()
	new_packet.cost_type = enum_selector.get_data() as AbilityCostPacket.CostType
	new_packet.cost_amount = value_box.value as int
	return new_packet
#endregion
