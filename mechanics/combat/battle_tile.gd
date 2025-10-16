## Contains all the functionality for the Tiles belonging to the BattleMap.
class_name BattleTile extends Node2D

#region Declarations
signal turn_finished

enum BattleState {
	EMPTY,
	ENEMY,
	OBSTACLE
}

@export var obj_sprite : AnimatedSprite2D
@export var select_sprite : AnimatedSprite2D
var hp : int = -1 :
	set(value):
		if not held_object:
			return
		
		if value <= 0:
			clear_object()
			hp = -1
		else:
			hp = value
var held_object : Variant
var tile_position : Vector2i = Vector2i.ZERO
var selectable : bool = false :
	set(value):
		if not value:
			select_sprite.play(&"default")
		else:
			select_sprite.play(&"selectable")
		
		selectable = value
var selected : bool = false :
	set(value):
		if not value:
			if selectable:
				select_sprite.play(&"selectable")
			else:
				select_sprite.play(&"default")
		else:
			select_sprite.play(&"selected")
		
		selected = value
var state : BattleState
#endregion

#region Built-Ins
func _ready() -> void:
	add_to_group(&"tiles")
#endregion

#region Setup
func attach_object(obj: Variant) -> void:
	if not obj is EnemyCharacter and not obj is ObstacleObject:
		return
	
	if obj is EnemyCharacter:
		state = BattleState.ENEMY
		hp = obj.stats.get(&"hp")
	else:
		state = BattleState.OBSTACLE
		hp = obj.stats.get(&"hp")
	
	held_object = obj
	name = obj.o_name
	obj_sprite.sprite_frames = obj.frames

func clear_object() -> void:
	if not held_object:
		return
	
	obj_sprite.sprite_frames = null
	held_object = null
	CombatManager.turn_tracker.remove_turn(self)
	name = "(%s, %s)" % [tile_position.x, tile_position.y]
	state = BattleState.EMPTY
	_check_other_tiles()
#endregion

#region Combat
func commit_action() -> void:
	attack()
	await GameGlobal.delay(0.5)
	turn_finished.emit()

func attack() -> void:
	if state != BattleState.ENEMY:
		return
	
	PlayerManager.hp -= held_object.attack()

func defend(ac: Action) -> void:
	if not state == BattleState.ENEMY or not selected:
		return
	
	hp -= held_object.defend(ac)
#endregion

#region Handling
func _check_other_tiles() -> void:
	var enemies : int = 0
	var tiles = get_tree().get_nodes_in_group(&"tiles")
	for tile in tiles:
		if tile.state == BattleState.ENEMY:
			enemies += 1
	
	if enemies == 0:
		GameGlobalEvents.battle_end.emit()

func _select(ac: Action) -> void:
	for tile in get_tree().get_nodes_in_group(&"tiles"):
		if tile.selected:
			tile.selected = false
		
		if tile.select_sprite.animation == &"adj_selected":
			if tile.selectable:
				tile.select_sprite.play(&"selectable")
			else:
				tile.select_sprite.play(&"default")
	
	selected = true
	if not ac:
		return
	
	var shape : Array[Vector2i] = ac.shape.shape_pos_arr
	shape.erase(Vector2i.ZERO)
	for vec in shape:
		for tile in get_tree().get_nodes_in_group(&"tiles"):
			if not tile.tile_position == tile_position + vec:
				continue
			
			tile.select_sprite.play(&"adj_selected")
#endregion

#region Signal Callbacks
func _on_gui_input(_viewport: Node, event: InputEvent, _idx: int) -> void:
	if not event is InputEventMouseButton or not selectable:
		return
	
	if event.double_click and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		_select(CombatManager.selected_action)
#endregion
