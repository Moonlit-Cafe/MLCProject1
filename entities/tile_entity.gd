## The Base Class for TileEntities, the actual Actors that exist on BattleMaps
class_name TileEntity extends Node3D

#region Declarations
enum EntityType {
	PLAYER,
	ENEMY
}

var entity_type : EntityType
var sprite : AnimatedSprite3D
var tile : BattleTile

var stats : Dictionary[Genum.StatType, float]
var hp : float = -1
var max_hp : int = 0
#endregion

#region Events
static func generate_entity(type: EntityType, battle_tile: BattleTile,
		character: Character = null) -> TileEntity:
	var new_entity = TileEntity.new()
	var new_sprite = AnimatableBody3D.new()
	
	new_entity.entity_type = type
	new_entity.tile = battle_tile
	new_entity.sprite = new_sprite
	if character:
		new_entity.stats = character.stats
		new_entity.hp = character.stats.get(Genum.StatType.HEALTH)
		new_entity.max_hp = new_entity.hp
	
	new_entity.add_child(new_sprite)
	return new_entity
#endregion
