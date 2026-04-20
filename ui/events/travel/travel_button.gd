class_name TravelButton extends Button
# TODO implement this
# should define what event should happen (steal from prog_scene)
# PLANNED change sprites as well, based on node type
# TODO Tyler needs to actually load the given scene (basically make this an alt to prog scene
# TODO implement draw_line()

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
	
func _process(delta: float) -> void:
	for other in others:
		if other.global_position != global_position:
			draw_connection(other)
	
	
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
	
	
func draw_connection(other):
	var connection = Line2D.new()
	add_child(connection)
	
	var start = Vector2(7.5, 0)
	connection.add_point(start)
	
	var o = other.position
	var s = self.position
	var diff = o - s + Vector2(12, 0)
	connection.add_point(diff)
#endregion
