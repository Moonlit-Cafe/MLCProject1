extends Camera2D

#region Declarations
@export var SPEED : float = 50.
@export var ZOOM_DELTA : float = 0.1
@export var ZOOM_MAX : float = 5.
@export var ZOOM_MIN : float = 1.
#endregion

#region Events
func _input(event: InputEvent) -> void:
	if not InputEventMouseButton:
		return
	
	if event.is_action(&"zoom_in") and zoom.length() < ZOOM_MAX:
		zoom += Vector2(ZOOM_DELTA, ZOOM_DELTA)
	elif event.is_action(&"zoom_out") and zoom.length() > ZOOM_MIN:
		zoom -= Vector2(ZOOM_DELTA, ZOOM_DELTA)
#endregion

#region Processes
func _process(delta: float) -> void:
	var dir = Input.get_vector(&"cam_left", &"cam_right", &"cam_up", &"cam_down")
	
	position += dir * SPEED * delta
	position.floor()
#endregion
