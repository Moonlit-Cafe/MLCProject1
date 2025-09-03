class_name EnemyCharacter extends Node2D

# TODO: Finish this
signal move_finished
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

var hp : float = 10.0
var p_def : float = 0.0
var m_def : float = 0.0
var p_atk : float = 1.0
var m_atk : float = 1.0
@export var haste : float = 10.0
var speed : int = 1
var ai_type : AIType = AIType.NULL
var current_state : EnemyState = EnemyState.ACTIVE

func _ready() -> void:
	add_to_group(&"enemies")
	
	if get_parent():
		board = get_parent()

func commit_action() -> void:
	#print("Starting Move")
	move()
	await move_finished
	#print("Starting Attack")
	attack()
	turn_finished.emit()

# TODO: Make this based on AIType later on.
func move() -> void:
	var pos_delta = board.board_tile_size
	var tween = create_tween().bind_node(self).set_loops(1)
	tween.tween_property(self, "position", Vector2(pos_delta.x, 0), 0.5).as_relative()
	await tween.finished
	move_finished.emit()

func attack() -> void:
	await GameGlobal.delay(0.5)
