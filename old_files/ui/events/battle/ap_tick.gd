extends Control
class_name APTick

#region Declarations
enum APState {
	EMPTY,
	USED,
	READY
}

@onready var empty_tex : TextureRect = $Empty
@onready var used_tex : TextureRect = $Used
@onready var ready_tex : TextureRect = $Ready

var current_state : APState :
	set(value):
		match(value):
			APState.EMPTY:
				empty_tex.show()
				used_tex.hide()
				ready_tex.hide()
			APState.USED:
				empty_tex.hide()
				used_tex.show()
				ready_tex.hide()
			APState.READY:
				empty_tex.hide()
				used_tex.hide()
				ready_tex.show()
		current_state = value
#endregion

#region Events
func empty() -> void:
	current_state = APState.EMPTY

func used() -> void:
	current_state = APState.USED

func ready() -> void:
	current_state = APState.READY
#endregion
