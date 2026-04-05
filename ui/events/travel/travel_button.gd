extends Button
# TODO implement this
# should define what event should happen (steal from prog_scene)
# modulate the star sprite based on event

#region Declarations
@onready var sprite = $Sprite2D

var scene : PackedScene
#endregion

#region Events
func init(scenes):
	scene = scenes[randi_range(0,scenes.size()-1)]
	_color_self()
	
	
func _color_self() -> void:
	var color
	match scene.event_id:
		&"shop":
			color = Color.YELLOW
		&"battle":
			color = Color.DIM_GRAY
		&"elite_battle":
			color = Color.DARK_KHAKI
		&"boss_battle":
			color = Color.DARK_RED
		&"craft":
			color = Color.SKY_BLUE
		&"unique":
			color = Color.PURPLE
			
		_:
			push_warning("Event of event_id %s not found!" % scene.event_id)
			return
			
	sprite.modulate(color)
#endregion
