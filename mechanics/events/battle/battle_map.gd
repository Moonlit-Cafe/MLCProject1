class_name BattleMap extends Node2D

#region Declarations
signal end_map
# TODO: Make BoardLayer a seperate thing so that we can switch maps on the fly.
# TODO: Make it so random enemies generate and can begin moving and attacking.
# TODO: Need to make action menu and turn tracker. Afterwards I'll have a prototype that's deliverable.

@export var battle_board : TileMapLayer
@export var turn_tracker : Control
@export var selectable_tile : PackedScene
@export var select_holder : Node2D

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

#region Built-Ins
func _ready() -> void:
	if not battle_board:
		return
	
	end_map.connect(func(): map_ended = true)
	scene = find_parent("BattleScene")
	
	board_tile_size = battle_board.tile_set.tile_size
	var corner := find_top_left_corner()
	if corner != Vector2i(search_range.x - 1, search_range.y + 1):
		board_area = determine_board(corner)
	
	GameGlobalEvents.action_selected.connect(_on_action_selected)
#endregion

#region Setup
func init() -> void:
	define_enemy_arrays()
	generate_turn_order()
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
	var enemy_orders = _get_enemy_order()
	var player_order = _get_player_order()
	turn_order = _zip_orders(player_order, enemy_orders)
	turn_tracker.turn_list = turn_order
	turn_tracker.generate_turns()
#endregion

#region Publics
@warning_ignore_start("integer_division")
func determine_selectables(shape: ActionShape) -> void:
	if not select_holder:
		return
	
	for child in select_holder.get_children():
		print("Freeing Child")
		child.queue_free()
	
	var shape_arr = shape.shape_pos_arr
	shape_arr.erase(Vector2i.ZERO)
	var d_space : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var param := PhysicsPointQueryParameters2D.new()
	param.collide_with_areas = true
	print(board_area.size.y)
	for x in range(board_area.size.x):
		for y in range(board_area.size.y):
			var point = Vector2(
				x * board_tile_size.x + board_tile_size.x / 2,
				((board_area.size.y - 1) - y) * board_tile_size.y + board_tile_size.y / 2
			)
			param.position = point + position
			var detected_enemies : Array = []
			var center_col = d_space.intersect_point(param)
			var detected : Array = []
			if center_col.size() == 0:
				detected = _get_shape_collisions(d_space, param, shape_arr)
				if detected.size() == 0:
					continue
				detected_enemies.append_array(detected)
				_create_selectable_tiles(point, detected_enemies, shape)
				continue
			
			if center_col.get(0).collider.owner is ObstacleObject:
				break
			
			var detected_enemy = center_col.pop_front().collider.owner
			if detected_enemy.is_queued_for_deletion():
				continue
			detected_enemies.append(detected_enemy)
			detected = _get_shape_collisions(d_space, param, shape_arr)
			detected_enemies.append_array(detected)
			_create_selectable_tiles(point, detected_enemies, shape)
@warning_ignore_restore("integer_division")
#endregion

#region Helpers
func _get_enemy_order() -> Array:
	var all_orders : Array = []
	for enemy in active_enemies:
		var enemy_order : Array = []
		@warning_ignore("integer_division")
		var turns : int = 1 if enemy.haste < 100 else (enemy.haste / 100) + 1
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
	if not "haste" in a or not "haste" in b:
		push_error("%s cannot be compared with %s since one doesn't have the haste attribute" % [a, b])
	
	return a.haste > b.haste

func get_tile_data(pos: Vector2) -> TileData:
	if not battle_board:
		return
	
	return battle_board.get_cell_tile_data(battle_board.local_to_map(pos))

func _get_shape_collisions(space: PhysicsDirectSpaceState2D, param: PhysicsPointQueryParameters2D, shape: Array[Vector2i]) -> Array:
	var detected_collisions : Array = []
	var pos = param.position
	for s_point in shape:
		param.position = pos + Vector2(s_point * board_tile_size.x)
		var off_col = space.intersect_point(param)
		if off_col.size() == 0:
			continue
		
		var detected = off_col.pop_front().collider.owner
		if detected is ObstacleObject:
			continue
		
		detected_collisions.append(detected)
	return detected_collisions

func _create_selectable_tiles(point: Vector2i, ref_enemies: Array, shape: ActionShape) -> void:
	var new_tile : SelectableTile = selectable_tile.instantiate()
	new_tile.ref_enemies = ref_enemies
	new_tile.shape = shape
	new_tile.position = point
	var bounds = Vector2(0, board_area.size.x * board_tile_size.x)
	new_tile.generate_highlights(board_tile_size.x, bounds)
	select_holder.add_child(new_tile)
#endregion

#region Signal Callbacks
# TODO: Need to make it so that based on the action shape it gathers all selectable enemies and highlights
# them.
func _on_action_selected(ac_shape: ActionShape) -> void:
	determine_selectables(ac_shape)
#endregion
