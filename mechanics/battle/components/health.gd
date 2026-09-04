class_name HealthComponent extends Node

#region Declarations
signal death

@export var max_amount : float = 0
var current_amount : float = 0
var remaining_amount : float :
	get:
		return current_amount / max_amount
#endregion

#region Statics
static func create_component(max_hp: float) -> HealthComponent:
	var new_health := HealthComponent.new()
	new_health.max_amount = max_hp
	return new_health
#endregion

#region Events
func _ready() -> void:
	if current_amount == 0:
		current_amount = max_amount

func apply_damage(damage: float) -> void:
	current_amount = clampf(current_amount - damage, 0, max_amount)
	if current_amount <= 0:
		death.emit()
#endregion
