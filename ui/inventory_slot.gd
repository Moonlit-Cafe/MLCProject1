## The UI item for actual holding ItemNodes
class_name InventorySlot extends Container

@export var snap_radius : float = 31
var held_item : ItemNode = null

#region Built-Ins
func _ready() -> void:
	add_to_group(&"inv_slots")
#endregion

#region Public Functions
func is_close(pos: Vector2) -> bool:
	return get_global_transform_with_canvas().get_origin().distance_to(pos) < snap_radius
#endregion
