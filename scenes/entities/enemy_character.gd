class_name EnemyCharacter extends Node2D

# TODO: Finish this
#region Declarations
signal turn_finished

enum AIType {
	NULL,
	MELEE,
	ARCHER,
	CASTER,
	HEALER,
	SUPPORTER
}

enum EnemyState {
	ACTIVE,
	BACKUP,
	SUPPORT
}

var board : Node2D

@export var haste : float = 10.0
@onready var select_sprite = $"SelectableSprite"
@onready var selected_sprite = $"SelectedSprite"

var hp : float = 10.0 :
	set(value):
		if value <= 0:
			GameGlobalEvents.battle_removed.emit(self)
			check_other_enemies()
			queue_free()
		else:
			hp = value
			print(hp)
var p_def : float = 0.0
var m_def : float = 0.0
var p_atk : float = 1.0
var m_atk : float = 0.0
var speed : int = 1
var ai_type : AIType = AIType.NULL
var map_pos : Vector2i = Vector2i.ZERO
var current_state : EnemyState = EnemyState.ACTIVE
var selectable : bool = false :
	set(value):
		if value:
			select_sprite.show()
		else:
			select_sprite.hide()
		selectable = value
var selected : bool = false :
	set(value):
		if value:
			check_selected()
			selected_sprite.show()
		else:
			selected_sprite.hide()
		selected = value
#endregion

#region Built-Ins
func _ready() -> void:
	add_to_group(&"enemies")
	
	if get_parent():
		board = get_parent()
#endregion

#region Actions
func commit_action() -> void:
	#print("Starting Attack")
	attack()
	await GameGlobal.delay(0.5)
	turn_finished.emit()

func attack() -> void:
	PlayerManager.hp -= p_atk + m_atk

func damage(ac: Action) -> void:
	if not selected:
		return
	
	var pos_arr := ac.shape.shape_pos_arr
	pos_arr.erase(Vector2i.ZERO)
	hp -= ac.value
	for pos in pos_arr:
		for enemy in get_tree().get_nodes_in_group(&"enemies"):
			enemy.hp -= ac.value
#endregion

#region Checks
func check_obstacles(ac_shape: ActionShape) -> void:
	# TODO: Replace so that weapons determine range, for now actions will
	if 7 - map_pos.y > ac_shape.action_range:
		return
	
	var ray := RayCast2D.new()
	ray.collide_with_areas = true
	add_child(ray)
	ray.target_position = Vector2(0, 20)
	ray.force_raycast_update()
	if ray.is_colliding():
		if ray.get_collider().owner is ObstacleObject:
			return
	selectable = true
	ray.queue_free()

func check_selected() -> void:
	var enemies = get_tree().get_nodes_in_group(&"enemies")
	enemies.erase(self)
	for enemy in enemies:
		if enemy.selected:
			enemy.selected = false

func check_other_enemies() -> void:
	if get_tree().get_node_count_in_group(&"enemies") <= 1:
		GameGlobalEvents.battle_end.emit()
#endregion

#region Signal Callbacks
func _on_selected(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not event is InputEventMouseButton or not board:
		return
	
	if not selectable:
		return
	
	if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		selected = true
#endregion
