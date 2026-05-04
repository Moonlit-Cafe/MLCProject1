extends CombatState

#func action_on_tiles() -> void:
#	# TODO: Attach to Battle_board instead of actuating here.
#	var tile : BattleTile = MouseHandler.selected_tile
#	var action = CombatManager.selected_action
#	battle_log.log_item("This is log test...")
#	
#	if not CombatManager.selected_action or not CombatManager.player_turn:
#		return
#		
#	var tile_pos := tile.tile_position
#	var center_pos := Vector2i(tile_pos.x, tile_pos.z)
#	var tiles := battle_map.grab_other_tiles(action.shape.shape_pos_arr.duplicate(), center_pos)
#	tiles.append(tile)
#	
#	for cur_tile in tiles:
#		_attack_tile(cur_tile, action)


#	MouseHandler.selected_tile = null
#	battle_map.determine_selectables()
#	CombatManager.player_turn = false
#	GameGlobalEvents.player_turn.emit()
#	CombatManager.use_action.emit()
