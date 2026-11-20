class_name TravelNode extends Button

#region Declarations
var links : Array = [] :
	set(new) :
		var t : Node2D
		var diff_vector : Vector2
		
		links = new
		
		for node in links:
			t = Line2D.new()
			
			diff_vector = node.global_position - self.global_position + Vector2.RIGHT * 100
			diff_vector.x /= 2
			diff_vector.x -= 10
			t.points = [Vector2.ZERO, diff_vector]
			
			t.position.x += 10
			t.z_index += 10
			add_child(t)
			
@export var selectable : bool = false 

@onready var hitbox : Area2D = $Area2D
@onready var travel_scene : TravelScene = get_parent()
#endregion

#region Events
func _ready() -> void:
	hitbox.mouse_entered.connect(_become_hovered)
	hitbox.mouse_exited.connect(_become_hovered)
	

## Handles triggers when node is clicked
func clicked() -> void:
	if not selectable:
		return
		
	travel_scene.cur_node = self
	travel_scene.highlight_selectables()
	travel_scene.visible = false
#endregion

#region Signal Callbacks
func _become_hovered() -> void:
	travel_scene.hovered_node = self
#endregion
