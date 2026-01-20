class_name TileEnemy extends TileEntity

#region Declarations
var current_state : EnemyCharacter.EnemyState = EnemyCharacter.EnemyState.ACTIVE
var haste : int
#endregion

#region Events
func _ready() -> void:
	add_to_group(&"enemy")

func update() -> void:
	if not character:
		push_error("Error: There is no enemy to update on node %s." % name)
		return
	
	haste = character.haste
	
	super()
#endregion
