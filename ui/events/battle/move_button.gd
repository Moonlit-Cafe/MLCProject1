class_name MoveButton extends DataButton

#region Events
func _ready() -> void:
	data = MoveAction.new()
	data.shape = ActionShape.new()
	data.shape = GameGlobal.resources.action_shape_compendium.get(&"ACS_0")
#endregion
