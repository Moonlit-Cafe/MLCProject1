class_name TileEntity extends Node3D

#region Declarations
@export var sprite : AnimatedSprite3D

var char : Variant
var parent_tile : BattleTile

var hp : int = -1 :
	set(value):
		#if not held_entity:
			#return
		
		if value <= 0:
			# PLANNED setup signal instead of double get_parent() call
			parent_tile.clear_object()
			hp = -1
		else:
			hp = value
var max_hp : int = 0
#endregion

#region Events
func update() -> void:
	if sprite:
		sprite.sprite_frames = char.frames
	
	position = Vector3(0., 8., 0) ## TODO: Need to either settle on an offset, or grab thie from Battle Map
	
	
func attack() -> void:
	if parent_tile.state != parent_tile.BattleState.ENEMY:
		return
	
	PlayerManager.hp -= char.attack()
	
func commit_action() -> void:
	attack()
	await GameGlobal.delay(0.5)
	parent_tile.turn_finished.emit()
	
	
func get_hp() -> Vector2i:
	return Vector2i(hp, max_hp)
	
	

#endregion
