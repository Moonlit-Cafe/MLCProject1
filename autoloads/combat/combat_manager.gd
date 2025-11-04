extends Node

#region Declarations
@export var enemy_compendium : Array[EnemyCharacter] = []
@export var obstacle_compendium : Array[ObstacleObject] = []

var current_board : BattleMap
var current_scene : BaseEventScene
var current_difficulty : float = 1
var selected_action : Action
var turn_tracker : Control
#endregion

#region Combat Loop
func battle_loop(rounds: int = -1, cur_round: int = 0) -> void:
	if not turn_tracker:
		return
	
	for actor in turn_tracker.turn_list:
		if actor is PlayerManager:
			current_scene.player_turn = true
			await GameGlobalEvents.player_turn
			turn_tracker.reorder_turns()
			continue
		
		actor.commit_action()
		await actor.turn_finished
		turn_tracker.reorder_turns()
		if current_board.map_ended:
			return
	
	if rounds == -1 and not current_board.map_ended:
		battle_loop()
	elif current_board.map_ended:
		return
	else:
		if cur_round < rounds:
			battle_loop(rounds, cur_round + 1)
		else:
			return
#endregion
