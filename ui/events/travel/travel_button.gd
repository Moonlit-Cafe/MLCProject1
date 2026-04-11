class_name TravelButton extends Button
# TODO implement this
# should define what event should happen (steal from prog_scene)
# modulate the star sprite based on event

#region Declarations
@onready var texture

var others :Array[TravelButton]
var scene 
#endregion

#region Events
func init(scenes):
	scene = scenes[randi_range(0,scenes.size()-1)]
	texture = $TextureRect
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
			
	texture.modulate = color
	
func link_path(other):
	others.append(other)
	# TODO Tyler add the part where there is visual linkage
#endregion
