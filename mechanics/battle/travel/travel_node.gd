class_name TravelNode extends Button

#region Declarations
var connections : Array = [] :
	set(new) :
		var t : Node2D
		var diff_vector : Vector2
		
		connections = new
		clear_lines()
		
		for node in connections:
			t = Line2D.new()
			
			diff_vector = node.global_position - self.global_position + Vector2.RIGHT * 100
			diff_vector.x /= 2
			diff_vector.x -= 10
			t.points = [Vector2.ZERO, diff_vector]
			
			t.position.x += 10
			t.z_index += 10
			add_child(t)
#endregion

#region Events
func clear_lines() -> void:
	for child in get_children():
		if child is Line2D:
			child.queue_free()
#endregion
