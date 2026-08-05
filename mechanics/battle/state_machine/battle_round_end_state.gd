## Handles any additional consequences or global actions that occur at the end of a round.
class_name BattleRoundEndState extends BattleState

#region Statics
static func generate_combat_state(t_line: Timeline) -> BattleRoundEndState:
	var new_state := BattleRoundEndState.new()
	new_state.timeline = t_line
	new_state.name = ROUND_END
	return new_state
#endregion

#region Events
func save_data() -> Dictionary:
	var dict : Dictionary = {}
	return dict
#endregion
