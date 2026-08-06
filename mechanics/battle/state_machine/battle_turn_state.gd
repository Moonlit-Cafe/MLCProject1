## Handles the turn of a single entity.
class_name BattleTurnState extends BattleState

#region Statics
static func generate_combat_state(t_line: Timeline) -> BattleTurnState:
	var new_state := BattleTurnState.new()
	new_state.timeline = t_line
	new_state.name = ENTITY_TURN
	return new_state
#endregion

#region Events
func save_data() -> Dictionary:
	var dict : Dictionary = {}
	return dict
#endregion
