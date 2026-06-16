class_name TileEnemy extends TileEntity

#region Declarations
var current_state : EnemyCharacter.EnemyState = EnemyCharacter.EnemyState.ACTIVE

#endregion

#region Events
func _ready() -> void:
	add_to_group(&"enemy")
	haste = 9
	add_to_group(&"unit")

func update() -> void:
	if not character:
		push_error("Error: There is no enemy to update on node %s." % name)
		return
	
	haste = character.haste
	
	super()
	
func die():
	# TODO Tyler Add money to game
	# make enemies drop money on die
	# make enemies drop items on die (sometimes later but always for now)
	# track money independently (player manager?)
	# gatekeep purchases behind money requirements
	
	super()
#endregion
