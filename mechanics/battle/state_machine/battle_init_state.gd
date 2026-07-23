class_name BattleInitState extends BattleState

#region Declarations
#endregion

#region Events
static func generate_combat_state(t_line: Timeline) -> BattleState:
	var new_state : BattleInitState = super(t_line)
	new_state.name = &"Init"
	return new_state

func update(_delta: float) -> void:
	pass
#endregion
