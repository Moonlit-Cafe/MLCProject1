class_name TravelNode extends Button

#region Declarations
var links : Array = [] :
	set(new) :
		var t : Node2D
		var diff_vector : Vector2
		
		links = new
		clear_lines()
		
		for node in links:
			t = Line2D.new()
			
			diff_vector = node.global_position - self.global_position + Vector2.RIGHT * 100
			diff_vector.x /= 2
			diff_vector.x -= 10
			t.points = [Vector2.ZERO, diff_vector]
			
			t.position.x += 10
			t.z_index += 10
			add_child(t)
			
			
var selectable : bool = false
var travel_scene : TravelScene
#endregion

#region Events
func _ready() -> void:
	travel_scene = get_parent() 
	$Area2D.area_entered.connect(travel_scene.update_node.bind(self))
	$Area2D.area_exited.connect(travel_scene.update_node.bind(self))

## Handles triggers when node is clicked
func clicked() -> void:
	if selectable:
		travel_scene.cur_node = self
		travel_scene.highlight_selectables()

## Removes all lines
func clear_lines() -> void:
	for child in get_children():
		if child is Line2D:
			child.queue_free()
#endregion
