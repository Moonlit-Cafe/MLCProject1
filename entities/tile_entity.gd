## The Base Class for TileEntities, the actual Actors that exist on BattleMaps
class_name TileEntity extends Node3D

#region Declarations
var entity_type : BaseCharacter.CharType
var sprite : AnimatedSprite3D
var tile : BattleTile

var stats : Dictionary[Genum.StatType, float]
var hp : float = -1
var max_hp : int = 0
#endregion

#region Events
static func generate_entity(type: BaseCharacter.CharType, character: BaseCharacter = null) -> TileEntity:
	var new_entity = TileEntity.new()
	var new_sprite = AnimatedSprite3D.new()
	new_sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	
	new_entity.entity_type = type
	new_entity.sprite = new_sprite
	if character:
		new_entity.stats = character.stats
		new_entity.hp = character.stats.get(Genum.StatType.HEALTH)
		new_entity.max_hp = new_entity.hp
		new_entity.sprite.sprite_frames = character.frames
	
	new_entity.add_child(new_sprite)
	return new_entity
#endregion
