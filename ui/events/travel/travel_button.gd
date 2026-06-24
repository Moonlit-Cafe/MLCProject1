class_name TravelButton extends Button

#PLANNED change sprites as well, based on node type

#region Declarations
@onready var texture

var others : Array[TravelButton]
var node_data
var travel_scene

signal next_scene(this_button: TravelButton)
#endregion

#region Events
func init(scenes):
	node_data = scenes[randi_range(0,scenes.size()-1)]
	texture = $TextureRect
	_color_self()
	draw.connect(draw_connections)
	pressed.connect(_on_pressed)
	
	
func _color_self() -> void:
	var color
	match node_data.event_id:
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
			push_warning("Event of event_id %s not found!" % node_data.event_id)
			return
			
	texture.modulate = color
	
	
func link_path(other):
	if other in others:
		push_warning("Repeated attempt to add node %s to node %s's others!" % [other, self])
		return
		
	others.append(other)
	
func disable_children(in_value):
	for o in others:
		o.disabled = in_value
	
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
		
func _on_pressed() -> void:
	travel_scene.last_node = self
	next_scene.emit(self)
#endregion
