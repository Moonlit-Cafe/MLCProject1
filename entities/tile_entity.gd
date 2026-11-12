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
	if new_entity == null:
		Global.logs.post_error(null, "Unknown entity type %s; cannot generate an entity." % type)
		return null
	var new_sprite = AnimatedSprite3D.new()
	new_sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	
	new_entity.entity_type = type
	new_entity.sprite = new_sprite
	if character:
		new_entity.stats = character.stats.duplicate()
		new_entity.sprite.sprite_frames = character.frames
		var max_hp : float = character.stats.get(Genum.StatType.HEALTH, 1.0)
		var new_hp := HealthComponent.create_component(max_hp)
		new_entity.health = new_hp
		new_entity.add_child(new_hp)
		if "action_set" in character and character.action_set and character.action_set.size() > 0:
			new_entity.load_data({&"action_set": character.action_set})
		elif character.get(&"actions") != null:
			var character_actions : ActionArray = character.get(&"actions")
			if character_actions.actions.size() > 0:
				var wrapped_set := ActionSet.new()
				wrapped_set.sets[ActionSet.Conditions.DEFAULT] = character_actions
				new_entity.load_data({&"action_set": wrapped_set})
	else:
		var default_stats : Dictionary[Genum.StatType, float] = {Genum.StatType.HEALTH: 10.0}
		new_entity.stats = default_stats
		var default_hp := HealthComponent.create_component(10.0)
		new_entity.health = default_hp
		new_entity.add_child(default_hp)
	
	new_entity.add_child(new_sprite)
	
	var util_ai := UtilityAI.new()
	new_entity.ai = util_ai
	new_entity.add_child(util_ai)
	util_ai.init(new_entity)
	
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
	
	new_entity.entity_type = data.get(&"e_type", BaseCharacter.CharType.ENEMY)
	var saved_stats : Dictionary[Genum.StatType, float] = data.get(&"stats", {})
	new_entity.stats = saved_stats
	var max_hp : float = data.get(&"max_hp", 1.0)
	var new_hp := HealthComponent.create_component(max_hp)
	new_entity.health = new_hp
	new_entity.health.current_amount = data.get(&"hp", max_hp)
	new_entity.load_data(data)
	
	new_entity.add_child(new_hp)
	new_entity.add_child(new_sprite)
	
	var util_ai := UtilityAI.new()
	new_entity.ai = util_ai
	new_entity.add_child(util_ai)
	util_ai.init(new_entity)
	
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
		&"sprite": sprite.sprite_frames if sprite else null,
		&"stats": stats if stats != null else {},
		&"hp": health.current_amount if health else 0.0,
		&"max_hp": health.max_amount if health else 0.0
	}
	return dict
#endregion
