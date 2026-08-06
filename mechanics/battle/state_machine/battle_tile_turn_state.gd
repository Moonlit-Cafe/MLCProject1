## Handles the resolution of all the tiles and their conditionals
class_name BattleTileTurnState extends BattleState

#region Statics
static func generate_combat_state(t_line: Timeline) -> BattleTileTurnState:
	var new_state := BattleTileTurnState.new()
	new_state.timeline = t_line
	new_state.name = TILE_TURN
	return new_state
#endregion

#region Events
func save_data() -> Dictionary:
	var dict : Dictionary = {}
	return dict
#endregion
