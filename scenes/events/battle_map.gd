## Handles the actual battle system, as in actually handling the order of enemies and what not.
class_name BattleMap extends Node2D

#region Declarations
signal end_map
# TODO: Make BoardLayer a seperate thing so that we can switch maps on the fly.
# TODO: Make it so random enemies generate and can begin moving and attacking.

@export var battle_board : TileMapLayer
@export var turn_tracker : Control
@export var select_holder : Node2D
@export var b_tile : PackedScene

# TODO: Change the entire scene to be a background with a custom grid definition 
# TODO: With the custom grid definition, selection should be possible with a gui_input over the whole map
# TODO: Action Selection should come from this selection process.
var scene : BaseEventScene
var active_enemies : Array[BattleTile] = []
var search_range := Vector2i(-100, 100)
var board : Array = []
var board_area : Rect2i
var board_tile_size : Vector2i
var map_ended : bool = false
#endregion

#region Events
func _ready() -> void:
	if not battle_board:
		return
	
	end_map.connect(func(): map_ended = true)
	scene = find_parent("BattleScene")
	
	board_tile_size = battle_board.tile_set.tile_size
	var corner := find_top_left_corner()
	if corner != Vector2i(search_range.x - 1, search_range.y + 1):
		board_area = determine_board(corner)
	
	_generate_board()

func find_top_left_corner() -> Vector2i:
	for y in range(search_range.x, search_range.y + 1):
		for x in range(search_range.x, search_range.y + 1):
			var data = battle_board.get_cell_tile_data(Vector2i(x, y))
			if data:
				return Vector2i(x, y)
	
	return Vector2i(search_range.x - 1, search_range.y + 1)
	
func find_player() -> Vector2i:
	for x in range(0, board.size()):
		for y in range(0, board[x].size()):
			var ent = board[x][y].held_entity
			if ent:
				if ent.character.o_name == &"Player":
					return Vector2i(x,y)
	
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

func _generate_board() -> void:
	if not b_tile:
		push_warning("There is no battle tile set in battle map scene...")
		return
	
	# _generate_surface()
	# _dectect_surface()
	var map : Array = []
	for x in range(board_area.size.x):
		map.append([])
		for y in range(board_area.size.y):
			var new_tile : BattleTile = b_tile.instantiate()
			new_tile.tile_position = Vector3i(x, y, 0)
			map.get(x).append(new_tile)
			select_holder.add_child(new_tile)
			new_tile.position = Vector3(x, y, 0) + Vector3() / 2
	
	board = map

func init() -> void:
	define_enemy_arrays()
	generate_turn_order()
	battle_loop()

func define_enemy_arrays() -> void:
	var all_tiles = get_tree().get_nodes_in_group(&"tiles")
	for tile in all_tiles:
		if not tile.state == BattleTile.BattleState.ENEMY:
			continue
		
		match(tile.held_entity.current_state):
			EnemyCharacter.EnemyState.ACTIVE:
				active_enemies.append(tile)

# TODO: Flesh this out so that it works for Support enemies, Allies, and the Player
func generate_turn_order() -> void:
	if not turn_tracker:
		return
	
	var turn_order = []
	var enemy_orders = _get_enemy_order()
	var player_order = _get_player_order()
	turn_order = _zip_orders(player_order, enemy_orders)
	turn_tracker.turn_list = turn_order
	turn_tracker.generate_turns()

func determine_selectables() -> void:
	if not select_holder:
		return
	
	for child in select_holder.get_children():
		child.selectable = false
	
	var player_pos:Vector2i = find_player()
	
	# TODO: Introduce some more checking on board_area and board later...
	# TODO this should also have considerations for the shape
		# could probably make this a function in the shape itself
		# that creates an array of xy coords based on the player pos
		# Then the board can validate if any of those positions exist
	for x in range(board.size()):
		if x != player_pos.x:
			continue
			
		for y in range(board.get(x).size()):
			if y >= CombatManager.selected_action.shape.action_range:
				break
			
			var tile = board.get(x).get(board.get(x).size() - (y + 1))
			if not tile:
				continue
			if tile.state == BattleTile.BattleState.OBSTACLE:
				tile.selectable = true
				break
			
			tile.selectable = true

func get_tile_at(pos: Vector2i) -> BattleTile:
	return board.get(pos.x).get(pos.y)

func _get_enemy_order() -> Array:
	var all_orders : Array = []
	for enemy in active_enemies:
		var enemy_order : Array = []
		@warning_ignore("integer_division")
		var turns : int = 1 if enemy.held_entity.haste < 100 else (enemy.held_entity.haste / 100) + 1
		for i in range(turns):
			enemy_order.append(enemy)
		all_orders.append(enemy_order)
	return all_orders

func _get_player_order() -> Array:
	var order : Array = []
	var haste : int = PlayerManager.combat_stats.get(Genum.StatType.HASTE)
	@warning_ignore("integer_division")
	var turns : int = 1 if haste < 100 else (haste / 100) + 1
	for i in range(turns):
		order.append(PlayerManager)
	return order

func _zip_orders(plr_order: Array, emy_order: Array) -> Array:
	var res_order : Array = []
	while plr_order.size() > 0 or _check_enemy_order_size(emy_order):
		var sub_order : Array = []
		sub_order.append(plr_order.pop_front())
		for enemy in emy_order:
			if enemy.size() == 0:
				continue
			
			sub_order.append(enemy.pop_front())
		sub_order.sort_custom(_haste_sort)
		res_order.append_array(sub_order)
	return res_order

func _check_enemy_order_size(emy_order: Array) -> int:
	var largest_size : int = 0
	for enemy in emy_order:
		if enemy.size() > largest_size:
			largest_size = enemy.size()
	return largest_size

func _haste_sort(a, b) -> bool:
	# TODO: Come back to this check later.
	#if (not "haste" in a.held_object and not a is PlayerManager) or (not "haste" in b.held_object and not b is PlayerManager):
	#	push_error("%s cannot be compared with %s since one doesn't have the haste attribute" % [a, b])
	
	var haste_a : int = PlayerManager.combat_stats.get(Genum.StatType.HASTE) if a is PlayerManager else a.held_entity.haste
	var haste_b : int = PlayerManager.combat_stats.get(Genum.StatType.HASTE) if b is PlayerManager else b.held_entity.haste
	return haste_a > haste_b

func get_tile_data(pos: Vector2) -> TileData:
	if not battle_board:
		return
	
	return battle_board.get_cell_tile_data(battle_board.local_to_map(pos))
#endregion

func battle_loop(rounds: int = -1, cur_round: int = 0) -> void:
	if not turn_tracker:
		return
	
	for actor in turn_tracker.turn_list:
		if actor is PlayerManager:
			CombatManager.player_turn = true
			await GameGlobalEvents.player_turn
			turn_tracker.recycle_turn()
			continue
		
		actor.held_entity.commit_action()
		await actor.turn_finished
		turn_tracker.recycle_turn()
		if map_ended:
			return
	
	_check_map_move()
	
	if rounds == -1 and not map_ended:
		battle_loop()
	elif map_ended:
		return
	else:
		if cur_round < rounds:
			battle_loop(rounds, cur_round + 1)
		else:
			return

func _check_map_move() -> void:
	var last_row : Array[BattleTile]
	for x in board:
		last_row.append(x.get(x.size() - 1))
	
	var can_move := true
	for tile in last_row:
		if tile.state != BattleTile.BattleState.EMPTY:
			can_move = false
			break
	
	if can_move:
		var pos := Vector2i.ZERO
		for x in board:
			pos.y = 0
			x = DataManipulationHelper.shift_array(x, 1)
			for tile in x:
				tile.tile_position = Vector3i(pos.x, pos.y, 0)
				tile.position = Vector2(pos.x * board_tile_size.x, pos.y * board_tile_size.y) + Vector2(board_tile_size) / 2
				pos.y += 1
			pos.x += 1
		determine_selectables()
		
