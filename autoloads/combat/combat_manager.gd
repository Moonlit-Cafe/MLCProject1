extends Node

#region Declarations
@warning_ignore("unused_signal")
signal tile_in_arr(tile: BattleTile)

@export var enemy_compendium : Array[EnemyCharacter] = []
@export var obstacle_compendium : Array[ObstacleObject] = []

var battle_map : BattleMap :
	set(value):
		battle_map = value
		if not value:
			return
		
		battle_map.end_map.connect(func(): battle_map = null)

var game_difficulty : float = 1
var difficulty_modifier : float = 1
var level_number : float = 1
var selected_action : Action
var player_turn : bool = true
#endregion

#region Events
func update_difficulty() -> void:
	# PLANNED: Come back to this for tweaking when demo-ing the game.
	difficulty_modifier = game_difficulty * pow(5, (level_number - 1) / 10)
#endregion
