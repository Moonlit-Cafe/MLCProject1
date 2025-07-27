class_name ItemNode extends Button

@export var item : Item = null
@export var initial_count : int = 0

var count: int:
	get:
		return count
	set(value):
		if value <= 0: item = null
		count = value

func _ready() -> void:
	count = initial_count
