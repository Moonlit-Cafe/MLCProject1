## The state managing setting up the start of a round.
class_name BattleRoundStartState extends BattleState

#region Statics
static func generate_combat_state(t_line: Timeline) -> BattleRoundStartState:
	var new_state := BattleRoundStartState.new()
	new_state.timeline = t_line
	new_state.name = ROUND_START
	return new_state as BattleRoundStartState
#endregion

#region Events
func save_data() -> Dictionary:
	var dict : Dictionary = {
		&"loaded_data": true
	}
	return dict
#endregion
