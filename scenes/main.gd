extends Node

#region Declarations
const BATTLE_SCENE : PackedScene = preload("res://scenes/events/battle_scene.tscn")
const TRAVEL_SCENE : PackedScene = preload("res://scenes/events/travel_scene.tscn")

@export var map_data : ZoneData
@export var travel_data : TravelData
#endregion

#region Events
func _ready() -> void:
	init_map()
	
func init_map() -> void:
	if not travel_data:
		Global.logs.post_error(self, "No Travel data loaded.")
		
	var t_scene : TravelScene = TRAVEL_SCENE.instantiate()
	t_scene.data = travel_data
	add_child(t_scene)
	
func init_battle() -> void:
	var b_scene : BattleScene = BATTLE_SCENE.instantiate()
	b_scene.zone_data = map_data
	add_child(b_scene)
	
func retreat() -> void:
	var scene = get_node("TravelScene")
	scene.visible = true
#endregion
