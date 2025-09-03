# The main scene for all battle handling.
extends BaseEventScene

var enemy_count : int = 0
var difficulty : float = 1.0
var reward_tier : int = 1
var elite_modifier : float = 1.0
var special_ability : bool = true
var boss_tier : int = 1
var boss_type : int = 1
var reward_multiplier : float = 1.0

# TODO: Move battle generation to this script later
# The actual battle generation will happen here and then get passed to board
# for right now it's all on the board

func _on_pressed() -> void:
	SceneManager.load_next_scene()
