## The interactable node that contains the data for an item in the inventory.
class_name ItemNode extends Button

#region Variables
@export var count_label : Label

@export var item : Item = null
@export var inv_pos : Vector2i = Vector2i(0, 0)

var count: int:
	get:
		return count
	set(value):
		if value <= 0: item = null
		if count_label: count_label.text = "%s" % value
		count = value
#endregion

func _process(_delta: float) -> void:
	if button_pressed:
		global_position = get_global_mouse_position() - (size / 2)

#region Signal Callbacks
func _on_released() -> void:
	if get_tree().has_group(&"inv_slots"):
		var closest_slot : InventorySlot = null
		for slot in get_tree().get_nodes_in_group(&"inv_slots"):
			if not closest_slot and slot.get_child_count() == 0:
				closest_slot = slot
			
			if slot.is_close(self.global_position):
				if closest_slot.global_position.distance_to(self.global_position) < slot.global_position.distance_to(self.global_position):
					continue
				if slot.get_child_count() == 0:
					closest_slot = slot
		get_parent().remove_child(self)
		closest_slot.add_child(self)
	
	position = Vector2.ZERO
#endregion
