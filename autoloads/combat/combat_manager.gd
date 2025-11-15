extends Node

#region Declarations
@export var enemy_compendium : Array[EnemyCharacter] = []
@export var obstacle_compendium : Array[ObstacleObject] = []

var game_difficulty : float = 1
var difficulty_modifier : float = 1
var level_number : float = 1
var selected_action : Action
var turn_tracker : Control
#endregion

#region Events
func update_difficulty() -> void:
	# PLANNED: Come back to this for tweaking when demo-ing the game.
	difficulty_modifier = game_difficulty * pow(5, (level_number - 1) / 10)
#endregion
