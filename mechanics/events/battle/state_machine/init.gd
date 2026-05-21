extends CombatState

#region Declarations
#endregion

#region Events
func update(_delta: float) -> void:
	combat_scene.battle_map.generate_board()
	_generate_battle()
	combat_scene.battle_map.init()
	finished.emit(ENTITY_TURN)

# TODO: Fix generation later
func _generate_battle() -> void:
	var enemy_count = 3
	
	var available_spots : Array[Vector2i]
	var board : Dictionary[Vector2i, BattleTile] = owner.battle_scene.battle_map.board
	var board_zone : MapBoundary = owner.battle_scene.battle_map.board_zone
	for tile in board.keys():
		if board.get(tile).state == BattleTile.BattleState.EMPTY:
			available_spots.append(tile)
	
	var start_pos = (board_zone.size / 2.0) as Vector3i + board_zone.pos - Vector3i.ONE
	start_pos = Vector2i(start_pos.x, start_pos.z)
	available_spots.erase(start_pos)
	board.get(start_pos).attach_object(PlayerManager.character_data)
	PlayerManager.entity_ref = board.get(start_pos).held_entity
	
	for i in range(enemy_count):
		start_pos = available_spots.pick_random()
		available_spots.erase(start_pos)
		print("Attached enemy on tile %s" % start_pos)
		board.get(start_pos).attach_object(CombatManager.enemy_compendium.get(0))
	
	var obstacle_count : int = 2
	for i in range(obstacle_count):
		start_pos = available_spots.pick_random()
		available_spots.erase(start_pos)
		board.get(start_pos).attach_object(CombatManager.obstacle_compendium.get(0))
#endregion
