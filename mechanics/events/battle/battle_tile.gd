## Contains all the functionality for the Tiles belonging to the BattleMap.
class_name BattleTile extends Node3D

# FIXME: There's a bug where the selection stops showing after an action takes place
# unless the player right-clicks.

#region Declarations
signal turn_finished

enum BattleState {
	EMPTY,
	ENEMY,
	OBSTACLE,
	PLAYER
}

#@export var select_sprite : AnimatedSprite3D
@export var packed_entity_reference : Dictionary[StringName, PackedScene]

@onready var entity_holder : Node3D = $EntityHolder
@onready var mesh : MeshInstance3D = $MeshInstance3D

var battle_map : Node2D
var held_entity : TileEntity
var tile_position : Vector3i = Vector3i.ZERO
var selectable : bool = false :
	set(value):
		if not value:
			mesh.set_instance_shader_parameter(&"mode", 0)
		else:
			mesh.set_instance_shader_parameter(&"mode", 1)
		
		selectable = value
var highlighted : bool = false :
	set(value):
		#if not value:
		#	if selectable:
		#		select_sprite.play(&"selectable")
		#	else:
		#		select_sprite.play(&"default")
		#else:
		#	select_sprite.play(&"selected")
		
		highlighted = value
var mouse_inside : bool = false
var state : BattleState
#endregion

#region Events
func _ready() -> void:
	add_to_group(&"tiles")
	battle_map = find_parent("BattleMap")

func attach_object(ent: Variant) -> void:
	if not ent is EnemyCharacter and not ent is ObstacleObject:
		return
	
	if ent is EnemyCharacter:
		state = BattleState.ENEMY
		var tile_e : TileEnemy = packed_entity_reference.get(&"enemy").instantiate()
		tile_e.char = ent
		held_entity = tile_e
		entity_holder.add_child(tile_e)
		held_entity.update()
		held_entity.hp = ent.stats.get(&"hp") * (CombatManager.difficulty_modifier * ent.stats_scaling.get(&"hp"))
	else:
		var tile_o : TileObstacle = packed_entity_reference.get(&"obstacle").instantiate()
		tile_o.char = ent
		held_entity = tile_o
		entity_holder.add_child(tile_o)
		held_entity.update()
		state = BattleState.OBSTACLE
		held_entity.hp = ent.stats.get(&"hp")
	
	held_entity.max_hp = held_entity.hp
	name = ent.o_name
	held_entity.parent_tile = self
	#obj_sprite.sprite_frames = ent.char.frames

func clear_object() -> void:
	if not held_entity:
		return
	
	held_entity.queue_free()
	held_entity = null
	GameGlobalEvents.battle_removed.emit(self)
	name = "(%s, %s)" % [tile_position.x, tile_position.y]
	state = BattleState.EMPTY
	_check_other_tiles()


func defend(ac: Action) -> void:
	var tiles = _get_all_tiles_in_shape(ac.shape)
	for tile in tiles:
		if tile.state == BattleState.EMPTY:
			continue
		tile.held_entity.hp -= tile.held_entity.char.defend(ac)

func get_hp() -> Vector2i:
	return held_entity.get_hp() 

func refresh_highlight() -> void:
	if mouse_inside:
		_highlight(CombatManager.selected_action)

func _get_all_tiles_in_shape(ac: ActionShape) -> Array[BattleTile]:
	var tiles_returned : Array[BattleTile] = []
	if not battle_map:
		for tile in get_tree().get_nodes_in_group(&"tiles"):
			if (tile.tile_position - tile_position) in ac.shape_pos_arr:
				tiles_returned.append(tile)
	else:
		for tile_pos in ac.shape_pos_arr:
			var pos_2d := Vector2i(tile_position.x, tile_position.y)
			tiles_returned.append(battle_map.get_tile_at(tile_pos + pos_2d))
	
	return tiles_returned

func _check_other_tiles() -> void:
	var enemies : int = 0
	var tiles = get_tree().get_nodes_in_group(&"tiles")
	for tile in tiles:
		if tile.state == BattleState.ENEMY:
			enemies += 1
	
	if enemies == 0:
		GameGlobalEvents.battle_end.emit()

func _highlight(ac: Action) -> void:
	if MouseHandler.selected_tile != null:
		return
	
	#for tile in get_tree().get_nodes_in_group(&"tiles"):
	#	if tile.highlighted:
	#		tile.highlighted = false
	#	
	#	if tile.select_sprite.animation == &"adj_selected":
	#		if tile.selectable:
	#			tile.select_sprite.play(&"selectable")
	#		else:
	#			tile.select_sprite.play(&"default")
	#
	#if not selectable:
	#	return
	#
	#highlighted = true
	#if not ac:
	#	return
	#
	#var shape : Array[Vector2i] = ac.shape.shape_pos_arr.duplicate()
	#shape.erase(Vector2i.ZERO)
	#for vec in shape:
	#	for tile in get_tree().get_nodes_in_group(&"tiles"):
	#		#if not tile.tile_position == tile_position + vec:
	#		#	continue
	#		
	#		tile.select_sprite.play(&"adj_selected")
#endregion

#region Signal Callbacks
func _on_gui_input(_camera: Node, event: InputEvent, _event_pos: Vector3, _normal: Vector3, _idx: int) -> void:
	if not event is InputEventMouseButton or not selectable:
		return
	
	if event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		MouseHandler.selected_tile = self

func _on_mouse_entered() -> void:
	if not CombatManager.selected_action:
		return
	
	mouse_inside = true
	_highlight(CombatManager.selected_action)

func _on_mouse_exited() -> void:
	mouse_inside = false
#endregion
