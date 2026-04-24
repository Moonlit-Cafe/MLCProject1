class_name TravelButton extends Button
# PLANNED change sprites as well, based on node type
# TODO Tyler needs to actually load the given scene (basically make this an alt to prog scene
# TODO implement a method that makes it so the lines are drawn

#region Declarations
@onready var texture
var others : Array[TravelButton]
var scene 
var travel_scene
#endregion

#region Events
func init(scenes):
	scene = scenes[randi_range(0,scenes.size()-1)]
	texture = $TextureRect
	_color_self()
	draw.connect(draw_connections)
	

	
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
	
	
func draw_connections():
	for other in others:
		var connection = Line2D.new()
		
		var start = Vector2(3, 5)
		connection.add_point(start)
		
		var o = other.position
		var s = self.position
		var diff = o - s + start + Vector2.RIGHT*10
		connection.add_point(diff)
		
		connection.width = 2
		connection.z_index = -10
		add_child(connection)
		
func _pressed():
	travel_scene.last_node = self
	#TODO travel_scene.load_this_stuff(self.scene)
#endregion
