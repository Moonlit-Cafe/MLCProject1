extends VBoxContainer

#region Declarations
@export var tick_scene : PackedScene

@onready var ap_bar : HBoxContainer = $APBar
@onready var hp_bar : TextureProgressBar = $HPBar
@onready var res_bar : TextureProgressBar = $ResBar

var ticks := Vector3i(0, 0, 0)
#endregion

#region Events
func get_ticks() -> Vector3i:
	return ticks

func update_ticks(new_tick: Vector3i) -> void:
	if new_tick.x > ticks.x:
		for amt in range(ticks.x - ap_bar.get_child_count()):
			var ap_tick = tick_scene.instantiate()
			ap_tick.empty()
			ap_bar.add_child(ap_tick)
			ticks = new_tick

func set_health(max_value: int, value: int = max_value) -> void:
	hp_bar.max_value = max_value
	hp_bar.value = value
	hp_bar.step = max_value / 1000.

func change_health(delta: int) -> void:
	hp_bar.value += delta

func set_resource(max_value: int, value: int = max_value) -> void:
	res_bar.max_value = max_value
	res_bar.value = value
	res_bar.step = max_value / 1000.
#endregion
