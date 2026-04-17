class_name TravelButton extends Button
# TODO implement this
# should define what event should happen (steal from prog_scene)
# modulate the star sprite based on event

# TODO actually give a sprite to buttons


# TODO Tyler needs to actually load the given scene (basically make this an alt to prog scene

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
	var connection = Line2D.new()
	other.add_child(connection)
	connection.add_point(Vector2.ZERO)
	var diff = other.global_position - self.global_position
	connection.add_point(diff)
	
#endregion
