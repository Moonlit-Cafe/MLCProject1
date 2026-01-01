class_name MoveButton extends DataButton

#region Events
func _ready() -> void:
	data = MoveAction.new()
	data.shape = ActionShape.new()
	# HACK magic numbers
	# should pull from PlayerManager
	data.shape = CombatManager.skill_manager.ac_shape_array[0]


#endregion
