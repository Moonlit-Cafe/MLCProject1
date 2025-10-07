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


@export var haste : int = 10
@onready var select_sprite = $"SelectableSprite"
@onready var selected_sprite = $"SelectedSprite"

var board : Node2D

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
	PlayerManager.hp -= int(p_atk + m_atk)

func damage(ac: Action) -> void:
	hp -= ac.value
#endregion

#region Checks
func check_other_enemies() -> void:
	if get_tree().get_node_count_in_group(&"enemies") <= 1:
		GameGlobalEvents.battle_end.emit()
#endregion
