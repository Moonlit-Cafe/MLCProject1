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
	var enemy_list : Array[EnemyCharacter] = GlobalResources.grab_enemies_with_tag(zone.enemy_tags)
	var enemy_count : int = floor(Global.difficulty * 3)
	for _i in range(enemy_count):
		var rand_tile := timeline.map.get_random_tile()
		while rand_tile.held_entity:
			rand_tile = timeline.map.get_random_tile()
		
		var e_data : EnemyCharacter = enemy_list.pick_random() #TODO: Change this to be based on timeline rng
		var e_entity := TileEntity.generate_entity(BaseCharacter.CharType.ENEMY, e_data)
		e_entity.add_to_group(&"enemy")
		rand_tile.held_entity = e_entity

func _generate_player() -> void:
	var zone : ZoneData = timeline.zone_data
	var rand_tile := timeline.map.get_random_tile()
	while rand_tile.held_entity:
		rand_tile = timeline.map.get_random_tile()
	
	# HACK this uses Enemy Data to spawn the player
	var p_data : BaseCharacter = GlobalResources.get_data(GlobalResources.DataType.CHARACTER, &"E001")
	var p_entity := TileEntityPlayer.generate_entity(BaseCharacter.CharType.ENEMY, p_data)
	p_entity.add_to_group(&"player")
	rand_tile.add_entity(p_entity)
	
#endregion
