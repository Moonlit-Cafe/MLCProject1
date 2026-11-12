class_name BattleInitState extends BattleState

#region Declarations
#endregion

#region Statics
static func generate_combat_state(t_line: Timeline) -> BattleInitState:
	var new_state := BattleInitState.new()
	new_state.timeline = t_line
	new_state.name = INIT
	return new_state
#endregion

#region Events
func enter(_previous_state: StringName, _data: Dictionary={}) -> void:
	_generate_enemies()
	_generate_player()
	finished.emit(ROUND_START, {})

func save_data() -> Dictionary:
	var dict : Dictionary = {
		&"loaded_data": true
	}
	return dict

func _generate_enemies() -> void:
	var zone : ZoneData = timeline.zone_data
	var all_characters : Array[Resource] = GlobalResources.tag_filter_entries("characters", zone.enemy_tags)
	var enemy_list : Array[EnemyCharacter] = []
	for character in all_characters:
		if character is EnemyCharacter:
			enemy_list.append(character)
	
	if enemy_list.is_empty():
		Global.logs.post_warning(self, "No enemy characters match this zone's tags; no enemies spawned.")
		return
	
	var enemy_count : int = floor(Global.difficulty * 3)
	for _i in range(enemy_count):
		var rand_tile : BattleTile = _find_empty_tile()
		if rand_tile == null:
			Global.logs.post_warning(self, "No empty tiles left; stopping enemy placement.")
			return
		
		var e_data : EnemyCharacter = enemy_list.pick_random() #TODO: Change this to be based on timeline rng
		var e_entity := TileEntity.generate_entity(BaseCharacter.CharType.ENEMY, e_data)
		if e_entity == null:
			continue
		e_entity.add_to_group(GroupNames.ENEMY)
		rand_tile.add_entity(e_entity)

func _find_empty_tile() -> BattleTile:
	var map : GameTileMap = timeline.map
	if map == null:
		return null
	var empty_tiles : Array[BattleTile] = []
	for tile : BattleTile in map.battle_tiles:
		if tile.held_entity == null:
			empty_tiles.append(tile)
	if empty_tiles.is_empty():
		return null
	return empty_tiles.pick_random()

func _generate_player() -> void:
	var rand_tile : BattleTile = _find_empty_tile()
	if rand_tile == null:
		Global.logs.post_warning(self, "No empty tiles left to place the player.")
		return
	
	var p_entity := TileEntityPlayer.generate_entity(BaseCharacter.CharType.PLAYER)
	p_entity.add_to_group(GroupNames.PLAYER)
	rand_tile.add_entity(p_entity)
#endregion
