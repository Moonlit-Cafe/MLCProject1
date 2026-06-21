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
	die_rewards()
	super()
	
	
func die_rewards():
	var drop_chance = true
	var item = GameGlobal.ResourceManager.item_compendium
	# TODO Tyler make enemies drop items on die (sometimes later but always for now)
	if drop_chance:
		PlayerManager.accept_item(item)
	PlayerManager.money += value

#endregion
