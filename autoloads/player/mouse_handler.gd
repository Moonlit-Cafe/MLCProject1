## Handles everything related to the Mouse and possibly allow this to be controlled by both an
## actual mouse but also with keyboard or gamepad if lacking a mouse.
extends Node2D

#region Declarations
@onready var container : InventorySlot = $ItemContainer

var prior_slot : InventorySlot
var hovered_slot : InventorySlot
#endregion

#region Events
func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if event.pressed and hovered_slot:
			if not hovered_slot.is_empty():
				if not container.held_item:
					_move_to_container()
				else:
					_move_to_prior()
					_move_to_container()
		elif not event.pressed and container.held_item:
			if not hovered_slot:
				_move_to_prior()
				return
			else:
				if not hovered_slot.is_empty():
					_move_to_prior()
				else:
					_move_to_hovered()

func _move_to_hovered() -> void:
	var item_to_move : ItemNode = container.held_item
	container.remove_child(item_to_move)
	hovered_slot.add_child(item_to_move)
	prior_slot = null
	item_to_move.position = Vector2.ZERO

func _move_to_prior() -> void:
	var item_to_move : ItemNode = container.held_item
	container.remove_child(item_to_move)
	prior_slot.add_child(item_to_move)
	prior_slot = null
	item_to_move.position = Vector2.ZERO

func _move_to_container() -> void:
	var item_to_move : ItemNode = hovered_slot.held_item
	hovered_slot.remove_child(item_to_move)
	container.add_child(item_to_move)
	item_to_move.position = Vector2.ZERO
	prior_slot = hovered_slot
#endregion

#region Processes
func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
#endregion

##region Drag and Drop System
#func _start_drag(mouse_pos: Vector2) -> void:
#	if not item:
#		return
#	
#	is_being_dragged = true
#	drag_offset = mouse_pos
#	z_index = 2
#	# TODO: Create visual feedback for dragging
#	# Thinking of either pulsating or a little "wiggle"
#
#func _handle_drag(mouse_motion: InputEventMouseMotion) -> void:
#	global_position = get_global_mouse_position() - drag_offset
#
#func _stop_drag() -> void:
#	is_being_dragged = false
#	z_index = 1
#	
#	# Find the closest valid slot
#	var closest_slot: InventorySlot = _find_closest_slot()
#	
#	if not closest_slot:
#		_return_to_original_position()
#		return
#	
#	if closest_slot.is_empty():
#		_move_to_slot(closest_slot)
#	elif closest_slot.can_combine_with(self):
#		if closest_slot.try_combine(self):
#			queue_free()
#		else:
#			_return_to_original_position()
#		
#		return
#	else:
#		# Swap items if slot is occupied and can't combine
#		_swap_with_slot(closest_slot)
##endregion
#
##region Drag and Drop Helpers
#func _find_closest_slot() -> InventorySlot:
#	var closest_slot: InventorySlot = null
#	var closest_distance: float = INF
#	
#	for slot in get_tree().get_nodes_in_group(&"inv_slots"):
#		if slot.is_close(global_position):
#			var distance = slot.global_position.distance_to(global_position)
#			if distance < closest_distance:
#				closest_distance = distance
#				closest_slot = slot
#	
#	return closest_slot
#
#func _move_to_slot(slot: InventorySlot) -> void:
#	if slot.can_slot != item.equip_loc and slot.can_slot != Genum.EquipLocation.INVENTORY:
#		_return_to_original_position()
#		return
#	
#	if get_parent():
#		get_parent().remove_child(self)
#	slot.add_child(self)
#	position = Vector2.ZERO
#
#func _swap_with_slot(slot: InventorySlot) -> void:
#	var other_item = slot.held_item
#	var original_parent = get_parent()
#	
#	_move_to_slot(slot)
#	
#	if other_item and original_parent:
#		other_item.get_parent().remove_child(other_item)
#		original_parent.add_child(other_item)
#		other_item.position = Vector2.ZERO
#
#func _return_to_original_position() -> void:
#	position = Vector2.ZERO
##endregion
