class_name BattleState extends State

#region Declarations
const INIT : StringName = &"Init"
const ENTITY_TURN : StringName = &"EntityTurn"
const ROUND_END : StringName = &"RoundEnd"
const BATTLE_END : StringName = &"BattleEnd"

var timeline : Timeline
#endregion

#region Events
static func generate_combat_state(t_line: Timeline) -> BattleState:
	var new_state := BattleState.new()
	new_state.timeline = t_line
	return new_state
#endregion
