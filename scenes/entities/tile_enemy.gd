class_name TileEnemy extends TileEntity

#region Declarations
var current_state : EnemyCharacter.EnemyState = EnemyCharacter.EnemyState.ACTIVE
var haste : int
#endregion

#region Events
func update() -> void:
	if not char:
		push_error("Error: There is no enemy to update on node %s." % name)
		return
	
	haste = char.haste
	
	super()
#endregion
