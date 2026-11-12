class_name HealthComponent extends Node

#region Declarations
signal death(component: HealthComponent)

@export var max_amount : float = 0
var current_amount : float = 0 :
	set(value):
		current_amount = value
		_amount_initialized = true
var _amount_initialized : bool = false
var remaining_amount : float :
	get:
		if max_amount <= 0.0:
			return 0.0
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
	if not _amount_initialized:
		current_amount = max_amount

func apply_damage(damage: float) -> void:
	var was_alive : bool = current_amount > 0.0
	current_amount = clampf(current_amount - damage, 0, max_amount)
	if was_alive and current_amount <= 0.0:
		death.emit(self)
#endregion
