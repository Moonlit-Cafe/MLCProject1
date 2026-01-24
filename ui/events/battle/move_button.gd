class_name MoveButton extends DataButton

#region Events
func _ready() -> void:
	data = MoveAction.new()
	data.shape = ActionShape.new()
	# HACK magic numbers
	# should pull from PlayerManager
	data.shape = CombatManager.skill_manager.find_shape(&"single_target")
#endregion
