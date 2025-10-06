class_name BattleMap extends Node2D

#region Declarations
signal end_map
# TODO: Make BoardLayer a seperate thing so that we can switch maps on the fly.
# TODO: Make it so random enemies generate and can begin moving and attacking.
# TODO: Need to make action menu and turn tracker. Afterwards I'll have a prototype that's deliverable.

@export var battle_board : TileMapLayer
@export var turn_tracker : Control

# TODO: Change the entire scene to be a background with a custom grid definition 
# TODO: With the custom grid definition, selection should be possible with a gui_input over the whole map
# TODO: Action Selection should come from this selection process.
var scene : BaseEventScene
var active_enemies : Array[EnemyCharacter] = []
var search_range := Vector2i(-100, 100)
var board_area : Rect2i
var board_tile_size : Vector2i
var map_ended : bool = false
#endregion

func _ready() -> void:
	if not battle_board:
		return
	
	end_map.connect(func(): map_ended = true)
	scene = find_parent("BattleScene")
	
	board_tile_size = battle_board.tile_set.tile_size
	var corner := find_top_left_corner()
	if corner != Vector2i(search_range.x - 1, search_range.y + 1):
		board_area = determine_board(corner)
		print(board_area)
	

func init() -> void:
	define_enemy_arrays()
	generate_turn_order()
	_detect_selectable_enemies()
	battle_loop()

func battle_loop(rounds: int = -1, cur_round: int = 0) -> void:
	if not turn_tracker:
		return
	
	for actor in turn_tracker.turn_list:
		if actor is PlayerManager:
			scene.player_turn = true
			await GameGlobalEvents.player_turn
			turn_tracker.reorder_turns()
			continue
		
		actor.commit_action()
		await actor.turn_finished
		turn_tracker.reorder_turns()
		if map_ended:
			return
	
	if rounds == -1 and not map_ended:
		battle_loop()
	elif map_ended:
		return
	else:
		if cur_round < rounds:
			battle_loop(rounds, cur_round + 1)
		else:
			return

func find_top_left_corner() -> Vector2i:
	for y in range(search_range.x, search_range.y + 1):
		for x in range(search_range.x, search_range.y + 1):
			var data = battle_board.get_cell_tile_data(Vector2i(x, y))
			if data:
				return Vector2i(x, y)
	
	return Vector2i(search_range.x - 1, search_range.y + 1)

func determine_board(init_pos: Vector2i) -> Rect2i:
	var area := Vector2i.ZERO
	var cur_pos := init_pos
	while area.x == 0 or area.y == 0:
		if area.x == 0:
			cur_pos.x += 1
			if not battle_board.get_cell_tile_data(cur_pos):
				area.x = cur_pos.x - init_pos.x
		else:
			if cur_pos.x != 0:
				cur_pos.x = 0
			cur_pos.y += 1
			if not battle_board.get_cell_tile_data(cur_pos):
				area.y = cur_pos.y - init_pos.y
	
	return Rect2i(init_pos, area)

func define_enemy_arrays() -> void:
	var all_enemies = get_tree().get_nodes_in_group(&"enemies")
	for enemy in all_enemies:
		if enemy is EnemyCharacter:
			match(enemy.current_state):
				EnemyCharacter.EnemyState.ACTIVE:
					active_enemies.append(enemy)

# TODO: Flesh this out so that it works for Support enemies, Allies, and the Player
func generate_turn_order() -> void:
	if not turn_tracker:
		return
	
	var turn_order = []
	turn_order.append_array(active_enemies)
	turn_order.append(PlayerManager)
	turn_order.sort_custom(_haste_sort)
	turn_tracker.turn_list = turn_order
	turn_tracker.generate_turns()

func _haste_sort(a, b) -> bool:
	if not "haste" in a or not "haste" in b:
		push_error("%s cannot be compared with %s since one doesn't have the haste attribute" % [a, b])
	
	return a.haste > b.haste

func get_tile_data(pos: Vector2) -> TileData:
	if not battle_board:
		return
	
	return battle_board.get_cell_tile_data(battle_board.local_to_map(pos))

# TODO: Need to make it so that based on the action shape it gathers all selectable enemies and highlights
# them.
func _on_action_select(ac_shape: ActionShape) -> void:
	_detect_selectable_enemies()

func _detect_selectable_enemies() -> void:
	for enemy in active_enemies:
		enemy.selectable = true
