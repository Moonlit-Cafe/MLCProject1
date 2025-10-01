# The main scene for all battle handling.
extends BaseEventScene

#region Declarations
@export var battle_viewport : SubViewportContainer
@export var battle_map : Node2D

var enemy_count : int = 0
var difficulty : float = 1.0
var reward_tier : int = 1
var elite_modifier : float = 1.0
var special_ability : bool = true
var boss_tier : int = 1
var boss_type : int = 1
var reward_multiplier : float = 1.0
#endregion
# TODO: Move battle generation to this script later
# The actual battle generation will happen here and then get passed to board
# for right now it's all on the board

#region Built-Ins
func _ready() -> void:
	_determine_battle_view_size()
	
	if battle_map:
		battle_map.end_map.connect(_on_map_ended)
#endregion

#region Setups
func _determine_battle_view_size() -> void:
	if not battle_viewport:
		push_warning("There is no viewport to change...")
		return
	
	# TODO: This is currently hard-coded, need to extrapolate later...
	var l = 176.
	var m = 1.
	var h_len = get_window().size.x * .4
	while l < h_len:
		m += 1
		l = 176 * m
	
	var h_size = l / get_window().size.x
	var v_size = l / get_window().size.y
	battle_viewport.anchor_top = (1 - v_size) / 2.
	battle_viewport.anchor_bottom = 1 - ((1 - v_size) / 2.)
	battle_viewport.anchor_left = (1 - h_size) / 2.
	battle_viewport.anchor_right = 1 - ((1 - h_size) / 2.)
	battle_viewport.stretch = m
#endregion

#region Signal Callbacks
func _on_pressed() -> void:
	SceneManager.load_next_scene()

func _on_map_ended() -> void:
	_on_pressed()

func _on_attack_pressed() -> void:
	battle_map.attack_enemy()
#endregion
