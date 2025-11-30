## Contains all the functionality for the Tiles belonging to the BattleMap.
class_name BattleTile extends Node2D

# FIXME: There's a bug where the selection stops showing after an action takes place
# unless the player right-clicks.

#region Declarations
signal turn_finished

enum BattleState {
	EMPTY,
	ENEMY,
	OBSTACLE
}

@export var obj_sprite : AnimatedSprite2D
@export var select_sprite : AnimatedSprite2D

var battle_map : Node2D
var hp : int = -1 :
	set(value):
		if not held_object:
			return
		
		if value <= 0:
			clear_object()
			hp = -1
		else:
			hp = value
var max_hp : int = 0
var held_object : Variant
var tile_position : Vector3i = Vector3i.ZERO
var selectable : bool = false :
	set(value):
		if not value:
			select_sprite.play(&"default")
		else:
			select_sprite.play(&"selectable")
		
		selectable = value
var highlighted : bool = false :
	set(value):
		if not value:
			if selectable:
				select_sprite.play(&"selectable")
			else:
				select_sprite.play(&"default")
		else:
			select_sprite.play(&"selected")
		
		highlighted = value
var mouse_inside : bool = false
var state : BattleState
#endregion

#region Events
func _ready() -> void:
	add_to_group(&"tiles")
	#battle_map = find_parent("BattleMap")

func attach_object(obj: Variant) -> void:
	if not obj is EnemyCharacter and not obj is ObstacleObject:
		return
	
	if obj is EnemyCharacter:
		state = BattleState.ENEMY
		hp = obj.stats.get(&"hp") * (CombatManager.difficulty_modifier * obj.stats_scaling.get(&"hp"))
	else:
		state = BattleState.OBSTACLE
		hp = obj.stats.get(&"hp")
	
	max_hp = hp
	
	held_object = obj
	name = obj.o_name
	obj_sprite.sprite_frames = obj.frames

func clear_object() -> void:
	if not held_object:
		return
	
	obj_sprite.sprite_frames = null
	held_object = null
	GameGlobalEvents.battle_removed.emit(self)
	name = "(%s, %s)" % [tile_position.x, tile_position.y]
	state = BattleState.EMPTY
	_check_other_tiles()

func commit_action() -> void:
	attack()
	await GameGlobal.delay(0.5)
	turn_finished.emit()

func attack() -> void:
	if state != BattleState.ENEMY:
		return
	
	PlayerManager.hp -= held_object.attack()

func defend(ac: Action) -> void:
	var tiles = _get_all_tiles_in_shape(ac.shape)
	for tile in tiles:
		if tile.state == BattleState.EMPTY:
			continue
		tile.hp -= tile.held_object.defend(ac)

func get_hp() -> Vector2i:
	return Vector2i(hp, max_hp)

func refresh_highlight() -> void:
	if mouse_inside:
		_highlight(CombatManager.selected_action)

func _get_all_tiles_in_shape(ac: ActionShape) -> Array[BattleTile]:
	var tiles_returned : Array[BattleTile] = []
	if not battle_map:
		for tile in get_tree().get_nodes_in_group(&"tiles"):
			if (tile.tile_position - tile_position) in ac.shape_pos_arr:
				tiles_returned.append(tile)
	#else:
	#	for tile_pos in ac.shape_pos_arr:
	#		tiles_returned.append(battle_map.get_tile_at(tile_pos + tile_position))
	
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
	
	for tile in get_tree().get_nodes_in_group(&"tiles"):
		if tile.highlighted:
			tile.highlighted = false
		
		if tile.select_sprite.animation == &"adj_selected":
			if tile.selectable:
				tile.select_sprite.play(&"selectable")
			else:
				tile.select_sprite.play(&"default")
	
	if not selectable:
		return
	
	highlighted = true
	if not ac:
		return
	
	var shape : Array[Vector2i] = ac.shape.shape_pos_arr.duplicate()
	shape.erase(Vector2i.ZERO)
	for vec in shape:
		for tile in get_tree().get_nodes_in_group(&"tiles"):
			#if not tile.tile_position == tile_position + vec:
			#	continue
			
			tile.select_sprite.play(&"adj_selected")
#endregion

#region Signal Callbacks
func _on_gui_input(_viewport: Node, event: InputEvent, _idx: int) -> void:
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
