## The Base Class for TileEntities, the actual Actors that exist on BattleMaps
class_name TileEntity extends Node3D

#region Declarations
var entity_type : BaseCharacter.CharType
var sprite : AnimatedSprite3D
var tile : BattleTile

var ai : DecisionMaker
var stats : Dictionary[Genum.StatType, float]
var health : HealthComponent
#endregion

#region Statics
static func generate_entity(type: BaseCharacter.CharType, character: BaseCharacter = null) -> TileEntity:
	var new_entity = _grab_entity_type(type)
	var new_sprite = AnimatedSprite3D.new()
	new_sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	
	new_entity.entity_type = type
	new_entity.sprite = new_sprite
	if character:
		new_entity.stats = character.stats
		new_entity.sprite.sprite_frames = character.frames
		var new_hp := HealthComponent.create_component(character.stats.get(Genum.StatType.HEALTH))
		new_entity.health = new_hp
		new_entity.add_child(new_hp)
		if character.action_set.size() > 0:
			new_entity.load_data({&"action_set": character.action_set})
	
	new_entity.add_child(new_sprite)
	
	var util_ai := UtilityAI.new()
	new_entity.ai = util_ai
	new_entity.add_child(util_ai)
	
	return new_entity

# TODO: Optimize this and the above to reduce redundancy
static func rebuild_entity(data: Dictionary[StringName, Variant]) -> TileEntity:
	var new_entity := _grab_entity_type(data.get(&"e_type"))
	if not new_entity:
		Global.logs.post_error(null, "The given entity_type does not match any expected.")
		return null
	var new_sprite := AnimatedSprite3D.new()
	new_sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	new_sprite.sprite_frames = data.get(&"sprite")
	
	new_entity.entity_type = data.get(&"e_type")
	new_entity.stats = data.get(&"stats")
	var new_hp := HealthComponent.create_component(data.get(&"max_hp"))
	new_entity.health = new_hp
	new_entity.health.current_amount = data.get(&"hp")
	new_entity.load_data(data)
	
	new_entity.add_child(new_hp)
	new_entity.add_child(new_sprite)
	
	var util_ai := UtilityAI.new()
	new_entity.ai = util_ai
	new_entity.add_child(util_ai)
	
	return new_entity

static func _grab_entity_type(e_type: BaseCharacter.CharType) -> TileEntity:
	var new_entity
	match(e_type):
		BaseCharacter.CharType.PLAYER:
			new_entity = TileEntityPlayer.new()
		BaseCharacter.CharType.ENEMY:
			new_entity = TileEntityEnemy.new()
		_:
			new_entity = null
	return new_entity
#endregion

#region Events
## Loads the remaining data that isn't included in [method rebuild_entity]
func load_data(_data: Dictionary) -> void:
	pass

func save_data() -> Dictionary[StringName, Variant]:
	var dict : Dictionary[StringName, Variant] = {
		&"e_type": entity_type,
		&"sprite": sprite.sprite_frames,
		&"stats": stats,
		&"hp": health.current_amount,
		&"max_hp": health.max_amount
	}
	return dict
#endregion
