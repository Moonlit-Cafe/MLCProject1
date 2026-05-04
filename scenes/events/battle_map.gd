## Handles the actual battle system, as in actually handling the order of enemies and what not.
class_name BattleMap extends Node3D

#region Declarations
signal end_map
# TODO: Make BoardLayer a seperate thing so that we can switch maps on the fly.
# TODO: Make it so random enemies generate and can begin moving and attacking.

@export var player_ref : PackedScene
@export var battle_board : GridMap ## The Gridmap that acts as the actual map for the battle
@export var turn_tracker : TurnTracker ## A local reference to the [TurnTracker]
@export var select_holder : Node3D
@export var b_tile : PackedScene
@export var board_zone : MapBoundary
@export var test_zone : ZoneResource

@onready var camera : BattleCam = $BattleCam

# TODO: Change the entire scene to be a background with a custom grid definition 
# TODO: With the custom grid definition, selection should be possible with a gui_input over the whole map
# TODO: Action Selection should come from this selection process.
var scene : BaseEventScene
var active_enemies : Array[TileEntity] = []
var board : Dictionary[Vector2i, BattleTile] = {}
var map_ended : bool = false
var tile_offset := Vector3(0.5, 1.501, 0.5)
var is_ready = false
#endregion

#region Events
func _ready() -> void:
	if not battle_board:
		return
	
	board_zone.scan_complete.connect(func(): is_ready = true)
	
	CombatManager.battle_end.emit()
	scene = find_parent("BattleScene")
	
	if not board_zone:
		push_warning("There is no defined boundary, exiting...")
		return
	
	var board_size := board_zone.size
	camera.init(Vector3(board_zone.pos) + Vector3(board_size.x, 0, board_size.z) / 2)
	_generate_board()

func _generate_board() -> void:
	if not b_tile:
		push_warning("There is no battle tile set in battle map scene...")
		return
	
	CombatManager.zone_manager.current_zone = test_zone
	CombatManager.zone_manager.generate_map(battle_board, board_zone)
	var surface_tiles := board_zone.scan_map(battle_board)
	var map : Dictionary[Vector2i, BattleTile] = {}
	for point in surface_tiles:
		var new_tile : BattleTile = b_tile.instantiate()
		new_tile.name = "Tile(%s,%s)" % [point.x, point.z]
		new_tile.tile_position = point
		map.set(Vector2i(point.x, point.z), new_tile)
		select_holder.add_child(new_tile)
		new_tile.position = battle_board.to_global(Vector3(new_tile.tile_position) + tile_offset)
	
	board = map.duplicate()

func init() -> void:
	if not ready:
		await board_zone.scan_complete
	
	define_enemy_arrays()
	generate_turn_order()
	battle_loop()
	pass

func define_enemy_arrays() -> void:
	for tile in board.values():
		if not tile.state == BattleTile.BattleState.ENEMY:
			continue
		
		match(tile.held_entity.character.current_state):
			EnemyCharacter.EnemyState.ACTIVE:
				active_enemies.append(tile.held_entity)

# TODO: Flesh this out so that it works for Support enemies, Allies, and the Player
func generate_turn_order() -> void:
	if not turn_tracker:
		return
	
	var turn_order : Array[TileEntity] = []
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
	
	# TODO: Introduce some more checking on board_area and board later...
	var new_range : float = 0.5
	var selected_action = CombatManager.selected_action
	if selected_action is CombatAction:
		new_range = selected_action.a_range
	elif selected_action is MoveAction:
		new_range = selected_action.move_range
	PlayerManager.entity_ref.d_range = new_range
	
	await get_tree().process_frame
	
	# TODO blowing self up crashes game
	var detected : Array[BattleTile] = await PlayerManager.entity_ref.get_detected()
	for tile in detected:
		if tile.held_entity:
			if tile.held_entity is not TileEntity:
				print("Tile %s not toggled", tile)
				continue

		tile.selectable = true


func get_tile_at(pos: Vector2i) -> BattleTile:
	return board.get(pos)

func _get_enemy_order() -> Array:
	var all_orders : Array = []
	for enemy in active_enemies:
		var enemy_order : Array[TileEntity] = []
		@warning_ignore("integer_division")
		var turns : int = 1 if enemy.haste < 100 else (enemy.haste / 100) + 1
		for i in range(turns):
			enemy_order.append(enemy)
		all_orders.append(enemy_order)
	return all_orders

func _get_player_order() -> Array[TileEntity]:
	var order : Array[TileEntity] = []
	var haste : int = PlayerManager.entity_ref.haste
	@warning_ignore("integer_division")
	var turns : int = 1 if haste < 100 else (haste / 100) + 1
	for i in range(turns):
		order.append(PlayerManager.entity_ref)
	return order

func _zip_orders(plr_order: Array[TileEntity], emy_order: Array) -> Array[TileEntity]:
	var res_order : Array[TileEntity] = []
	while plr_order.size() > 0 or _check_enemy_order_size(emy_order):
		var sub_order : Array[TileEntity] = []
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

func _haste_sort(a: TileEntity, b: TileEntity) -> bool:
	# TODO: Come back to this check later.
	# if (not "haste" in a.held_object and not a is PlayerManager) or (not "haste" in b.held_object and not b is PlayerManager):
	# push_error("%s cannot be compared with %s since one doesn't have the haste attribute" % [a, b])
	
	var haste_a : int = a.haste
	var haste_b : int = b.haste
	return haste_a > haste_b

func get_tile_data(pos: Vector3) -> int:
	if not battle_board:
		return GridMap.INVALID_CELL_ITEM
	
	return battle_board.get_cell_item(battle_board.local_to_map(pos))

func grab_other_tiles(tiles_to_grab: Array[Vector2i], center_pos) -> Array[BattleTile]:
	var ret_arr : Array[BattleTile] = []
	if Vector2i.ZERO in tiles_to_grab:
		tiles_to_grab.erase(Vector2i.ZERO)
	
	
	for tile_coords in tiles_to_grab:
		var cur_coord = tile_coords + center_pos
		if not check_tile_exists(cur_coord):
			continue
		ret_arr.append(board.get(cur_coord))
	
	return ret_arr

func check_tile_empty(pos: Vector2i) -> bool:
	if not check_tile_exists(pos):
		return false
	
	var tile : BattleTile = board.get(pos)
	
	if not tile.held_entity:
		return true
	return false

func check_tile_exists(pos: Vector2i) -> bool:
	if not pos in board.keys():
		return false
	return true

func move_to_tile(cur_pos: Vector2i, dir: Vector2i) -> void:
	var source_tile : BattleTile = board.get(cur_pos)
	if not check_tile_empty(cur_pos + dir):
		return
	
	var target_tile : BattleTile = board.get(cur_pos + dir)
	target_tile.attach_entity(source_tile.held_entity)

func dir_to_player(pos: Vector2i) -> Vector2i:
	var source_tile : BattleTile = board.get(pos)
	var player_tile : BattleTile = PlayerManager.occupied_tile
	var x_dist : int = player_tile.tile_position.x - source_tile.tile_position.x
	var z_dist : int = player_tile.tile_position.z - source_tile.tile_position.z
	
	if abs(x_dist) > abs(z_dist):
		if x_dist > 0:
			return Vector2i(1, 0)
		return Vector2i(-1, 0)
	else:
		if z_dist > 0:
			return Vector2i(0, 1)
		return Vector2i(0, -1)

func dist_to_player(pos: Vector2i) -> float:
	var source_tile : BattleTile = board.get(pos)
	var player_tile : BattleTile = PlayerManager.occupied_tile
	var x_dist : int = player_tile.tile_position.x - source_tile.tile_position.x
	var z_dist : int = player_tile.tile_position.z - source_tile.tile_position.z
	var distance = Vector2i(x_dist, z_dist).length()
	return distance
#endregion

func battle_loop(rounds: int = -1, cur_round: int = 0) -> void:
	if not turn_tracker:
		return
	
	print(turn_tracker.turn_list)
	for actor in turn_tracker.turn_list:
		if actor is TilePlayer:
			CombatManager.player_turn = true
			await GameGlobalEvents.player_turn
			turn_tracker.recycle_turn()
			continue
		
		print("%s: Committing Action" % actor.name)
		actor.commit_action()
		await actor.parent_tile.turn_finished
		turn_tracker.recycle_turn()
		if map_ended:
			return
	
	#_check_map_move()
	
	if rounds == -1 and not map_ended:
		battle_loop()
	elif map_ended:
		return
	else:
		if cur_round < rounds:
			battle_loop(rounds, cur_round + 1)
		else:
			return 
			
			
#region Signal Callbacks
func _on_new_turn(cur_is_player : bool):
	camera.player_turn = cur_is_player
#endregion
