class_name ItemNode extends Button

@export var item : Item = null
@export var initial_count : int = 0
@export var inv_pos : Vector2i = Vector2i(0, 0)

var count: int:
	get:
		return count
	set(value):
		if value <= 0: item = null
		count = value

func _ready() -> void:
	count = initial_count
