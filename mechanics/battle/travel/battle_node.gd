class_name BattleNode extends TravelNode

#region Events
## Handles triggers when node is clicked
func clicked() -> void:
	get_parent().get_parent().init_battle()
	
	super()
#endregion
