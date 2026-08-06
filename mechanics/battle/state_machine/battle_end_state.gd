## Handles everything relating to the end of a battle.
class_name BattleEndState extends BattleState

#region Statics
static func generate_combat_state(t_line: Timeline) -> BattleEndState:
	var new_state := BattleEndState.new()
	new_state.timeline = t_line
	new_state.name = BATTLE_END
	return new_state
#endregion

#region Events
func save_data() -> Dictionary:
	var dict : Dictionary = {}
	return dict
#endregion
