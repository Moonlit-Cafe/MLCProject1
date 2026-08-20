extends Node

#region Declarations
const BATTLE_SCENE : PackedScene = preload("res://scenes/events/battle_scene.tscn")

@export var map_data : ZoneData
#endregion

#region Events
func _ready() -> void:
	init_battle()
	
func init_battle() -> void:
	var b_scene : BattleScene = BATTLE_SCENE.instantiate()
	b_scene.zone_data = map_data
	add_child(b_scene)
#endregion
