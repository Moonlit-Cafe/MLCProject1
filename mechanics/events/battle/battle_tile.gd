## Contains all the functionality for the Tiles belonging to the BattleMap.
class_name BattleTile extends Node3D

# FIXME: There's a bug where the selection stops showing after an action takes place
# unless the player right-clicks.

#region Declarations
signal turn_finished ## Emitted when the Tile's Char's turn is finished.

## The available battle States for the tile
# TODO: Possibly remove this, possibly redundant on account of usually checking for entity's char
enum BattleState {
	EMPTY,
	ENEMY,
	OBSTACLE,
	PLAYER
}

## The highlight state of the tile
enum Highlight {
	NULL,
	SELECTABLE,
	SELECTED,
	ADJACENT
}

#@export var select_sprite : AnimatedSprite3D
## Holds a dictionary of different entities to then instantiate on the tile.
# TODO: Probably move this outside of the tile and use a master compendium to draw from instead.
@export var packed_entity_reference : Dictionary[StringName, PackedScene]
## The colors for the highlight
@export var selection_colors : Dictionary[Highlight, Color]

## The node incharge of holding the actual entity of the tile.
@onready var entity_holder : Node3D = $EntityHolder
## The sprite responsible for our selection animation.
@onready var select_sprite : AnimatedSprite3D = $AnimatedSprite3D
#@onready var mesh : MeshInstance3D = $MeshInstance3D

var battle_map : BattleMap3D ## Parent+ reference to the current battle_map
var held_entity : TileEntity ## The currently held entity reference
var tile_position : Vector3i = Vector3i.ZERO ## The position within [member battle_map]
## If the tile is currently selectable or not
var selectable : bool = false :
	set(value):
		if not value:
			_set_highlight(Highlight.NULL)
		else:
			_set_highlight(Highlight.SELECTABLE)
		
		selectable = value
## If the tile is currently highlighted or not
var highlighted : bool = false :
	set(value):
		if not value:
			if selectable:
				_set_highlight(Highlight.SELECTABLE)
			else:
				_set_highlight(Highlight.NULL)
		else:
			if self == MouseHandler.hovered_tile:
				_set_highlight(Highlight.SELECTED)
			else:
				_set_highlight(Highlight.ADJACENT)
		
		highlighted = value
var state : BattleState ## The current state of the tile
#endregion

#region Events
func _ready() -> void:
	add_to_group(&"tiles")
	CombatManager.tile_signal_pool.add_to_group("tiles", self)
	battle_map = find_parent("BattleMap3D")

## Attaches the character resource, [param ent], by generating the respective entity, attaching it
## and then making it a child of [member entity_holder]
func attach_object(ent: CharacterResource) -> void:
	var tile := _gen_tile_entity(ent)
	
	if ent is PlayerCharacter:
		state = BattleState.PLAYER
		PlayerManager.occupied_tile = self
	elif ent is EnemyCharacter:
		state = BattleState.ENEMY
	elif ent is ObstacleObject:
		state = BattleState.OBSTACLE
	
	tile.character = ent
	tile.character.init()
	held_entity = tile
	held_entity.stats = tile.character.stats.duplicate()
	entity_holder.add_child(tile)
	held_entity.update()
	tile.position = Vector3.ZERO
	
	name = held_entity.character.o_name
	held_entity.parent_tile = self

## Attaches an already existing entity to this tile, usually used for moving between tiles
func attach_entity(entity: TileEntity) -> void:
	if held_entity:
		return
	
	var source = entity.get_parent()
	source.remove_child(entity)
	source.name = "(%s, %s)" % [tile_position.x, tile_position.z]
	entity.parent_tile.held_entity = null
	entity_holder.add_child(entity)
	entity.position = Vector3.ZERO
	held_entity = entity
	name = held_entity.character.o_name

## Clears out the object and all the data relevant to it
func clear_object() -> void:
	if not held_entity:
		return
	
	held_entity.queue_free()
	held_entity = null
	GameGlobalEvents.battle_removed.emit(self)
	name = "(%s, %s)" % [tile_position.x, tile_position.z]
	state = BattleState.EMPTY

## Return the current hp value of [member held_entity]
func get_hp() -> Vector2i:
	return held_entity.get_hp() 

## Generates a [TileEntity] from a given [CharacterResource]
func _gen_tile_entity(ent: CharacterResource) -> TileEntity:
	if ent is PlayerCharacter:
		return packed_entity_reference.get(&"player").instantiate()
	elif ent is EnemyCharacter:
		return packed_entity_reference.get(&"enemy").instantiate()
	elif ent is ObstacleObject:
		return packed_entity_reference.get(&"obstacle").instantiate()
	else:
		return null

## The entire highlighting logic for the tile.
func _set_highlight(idx: int) -> void:
	#mesh.set_instance_shader_parameter(&"mode", idx)
	var frame : int = select_sprite.get_frame()
	var progress : float = select_sprite.get_frame_progress()
	match (idx):
		Highlight.NULL:
			select_sprite.play("default")
			select_sprite.modulate = selection_colors.get(Highlight.NULL)
		Highlight.SELECTABLE:
			select_sprite.play("selectable_still")
			select_sprite.set_frame_and_progress(frame, progress)
			select_sprite.modulate = selection_colors.get(Highlight.SELECTABLE)
		Highlight.SELECTED:
			select_sprite.play("selected")
			select_sprite.modulate = selection_colors.get(Highlight.SELECTED)
		Highlight.ADJACENT:
			select_sprite.play("selectable_fade")
			select_sprite.set_frame_and_progress(frame, progress)
			select_sprite.modulate = selection_colors.get(Highlight.ADJACENT)
#endregion

#region Signal Callbacks
func _on_gui_input(_camera: Node, event: InputEvent, _event_pos: Vector3, _normal: Vector3, _idx: int) -> void:
	if not event is InputEventMouseButton or not selectable:
		return
	
	if event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		highlighted = true
		MouseHandler.selected_tile = self
#endregion
