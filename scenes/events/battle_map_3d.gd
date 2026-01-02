## Handles the actual battle system, as in actually handling the order of enemies and what not.
class_name BattleMap3D extends Node3D

#region Declarations
signal end_map
# TODO: Make BoardLayer a seperate thing so that we can switch maps on the fly.
# TODO: Make it so random enemies generate and can begin moving and attacking.

@export var player_ref : PackedScene
@export var battle_board : GridMap
@export var turn_tracker : Control
@export var select_holder : Node3D
@export var b_tile : PackedScene
@export var board_zone : MapBoundary
@export var test_zone : ZoneResource

@onready var camera : BattleCam = $BattleCam

# TODO: Change the entire scene to be a background with a custom grid definition 
# TODO: With the custom grid definition, selection should be possible with a gui_input over the whole map
# TODO: Action Selection should come from this selection process.
var scene : BaseEventScene
var active_enemies : Array[BattleTile] = []
var board : Dictionary[Vector2i, BattleTile] = {}
var map_ended : bool = false
var tile_offset := Vector3(0.5, 1.501, 0.5)
var player : TilePlayer
var is_ready = false
#endregion

#region Events
func _ready() -> void:
	if not battle_board:
		return
	
	board_zone.scan_complete.connect(func(): is_ready = true)
	
	end_map.connect(func(): map_ended = true)
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
	
	determine_selectables()
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
	
	# TODO: Introduce some more checking on board_area and board later...
	await get_tree().process_frame
	player.range = CombatManager.selected_action.shape.action_range
	var detected := await player.get_detected()
	for tile in detected:
		tile.selectable = true

func get_tile_at(pos: Vector2i) -> BattleTile:
	return board.get(pos)

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

func get_tile_data(pos: Vector3) -> int:
	if not battle_board:
		return GridMap.INVALID_CELL_ITEM
	
	return battle_board.get_cell_item(battle_board.local_to_map(pos))
#endregion

func battle_loop(rounds: int = -1, cur_round: int = 0) -> void:
	if not turn_tracker:
		return
	
	for actor in turn_tracker.turn_list:
		if actor is PlayerManager:
			CombatManager.player_turn = true
			await GameGlobalEvents.player_turn
			turn_tracker.reorder_turns()
			continue
		
		actor.commit_action()
		await actor.turn_finished
		turn_tracker.reorder_turns()
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
