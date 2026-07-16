class_name TileEnemy extends TileEntity

#region Declarations
var current_state : EnemyCharacter.EnemyState = EnemyCharacter.EnemyState.ACTIVE
var value : int = 10
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
	# TYLER killing an enemy locks the game
	# their turn isnt removed from the queue
	die_rewards()
	super()
	
	
func die_rewards():
	# TODO make items only sometimes drop
	var drop_chance = true
	var item :Item = GameGlobal.resources.item_compendium["MAT_0"]
	PlayerManager.money += value
	if drop_chance:
		PlayerManager.accept_item(item)

#endregion
