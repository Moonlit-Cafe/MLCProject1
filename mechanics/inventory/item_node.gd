## The interactable node that contains the data for an item in the inventory.
class_name ItemNode extends Control

# FIXME: There's a bug where if you place the node in the right spot between slots
# that it'll bring the item count to 1 for whatever reason.

#region Declarations
@export_category("Node References")
@export var count_label : Label
@export var texture : TextureRect
@export_category("Item and Node Data")
@export var item : Item = null
@export var inv_pos : Vector2i = Vector2i(0, 0)

var count: int:
	get:
		return count
	set(value):
		if value <= 0: item = null
		if count_label: count_label.text = "%s" % value
		count = value
		update_display()

# REMOVE: This drag behavior should be handled by a more robust system
# Consider using Godot's built-in drag and drop or a dedicated drag manager
var is_being_dragged: bool = false
var drag_offset: Vector2 = Vector2.ZERO
#endregion

#region Built-Ins
func _ready() -> void:
	# Initialize the item display
	update_display()
	# TODO: Connect to CraftManager for texture atlas
	# if item and CraftManager:
	#     icon = CraftManager.get_item_texture(item.texture)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				_start_drag(mouse_event.position)
			else:
				_stop_drag()
	elif event is InputEventMouseMotion and is_being_dragged:
		_handle_drag(event as InputEventMouseMotion)
#endregion

#region Item Helpers
## Initialize item display
func setup_item(new_item: Item, initial_count: int = 1) -> void:
	item = new_item
	count = initial_count
	update_display()

# Update the visual display of the item
func update_display() -> void:
	if not item:
		queue_free()
		return
	
	# Set the icon from texture atlas
	if item.texture != Vector2i.ZERO:
		texture.texture = CraftManager.get_item_texture(item.texture)
	
	# Update count display
	if count_label:
		count_label.text = str(count) if count > 1 else ""
		count_label.visible = count > 1
#endregion

#region Drag and Drop System
## Check if this item can stack with another
func can_stack_with(other_item: Item) -> bool:
	if not item or not other_item:
		return false
	return item.id == other_item.id

# Add to stack if possible
func add_to_stack(amount: int) -> int:
	if amount + count <= item.max_stack_size:
		count += amount
		return 0
	else:
		var initial_count = count
		count = item.max_stack_size
		return amount + initial_count - item.max_stack_size

## Remove from stack
func remove_from_stack(amount: int) -> int:
	var removed = mini(amount, count)
	count -= removed
	if count <= 0:
		item = null
		update_display()
	return removed

# Split the stack into two
func split_stack(split_amount: int) -> ItemNode:
	if split_amount >= count or split_amount <= 0:
		return null
	
	# Create new ItemNode for the split
	var new_node = ItemNode.new()
	new_node.setup_item(item, split_amount)
	
	# Reduce current stack
	count -= split_amount
	update_display()
	
	return new_node
#endregion

#region Drag and Drop System
func _start_drag(mouse_pos: Vector2) -> void:
	if not item:
		return
	
	is_being_dragged = true
	drag_offset = mouse_pos
	z_index = 2
	# TODO: Create visual feedback for dragging
	# Thinking of either pulsating or a little "wiggle"

func _handle_drag(mouse_motion: InputEventMouseMotion) -> void:
	global_position = get_global_mouse_position() - drag_offset

func _stop_drag() -> void:
	is_being_dragged = false
	z_index = 1
	
	# Find the closest valid slot
	var closest_slot: InventorySlot = _find_closest_slot()
	
	if not closest_slot:
		_return_to_original_position()
		return
	
	if closest_slot.is_empty():
		_move_to_slot(closest_slot)
	elif closest_slot.can_combine_with(self):
		if closest_slot.try_combine(self):
			queue_free()
		else:
			_return_to_original_position()
		
		return
	else:
		# Swap items if slot is occupied and can't combine
		_swap_with_slot(closest_slot)
#endregion

#region Drag and Drop Helpers
func _find_closest_slot() -> InventorySlot:
	var closest_slot: InventorySlot = null
	var closest_distance: float = INF
	
	for slot in get_tree().get_nodes_in_group(&"inv_slots"):
		if slot.is_close(global_position):
			var distance = slot.global_position.distance_to(global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_slot = slot
	
	return closest_slot

func _move_to_slot(slot: InventorySlot) -> void:
	if slot.can_slot != item.equip_loc and slot.can_slot != Genum.EquipLocation.INVENTORY:
		_return_to_original_position()
		return
	
	if get_parent():
		get_parent().remove_child(self)
	slot.add_child(self)
	position = Vector2.ZERO

func _swap_with_slot(slot: InventorySlot) -> void:
	var other_item = slot.take_item()
	var original_parent = get_parent()
	
	_move_to_slot(slot)
	
	if other_item and original_parent:
		original_parent.add_child(other_item)
		other_item.position = Vector2.ZERO

func _return_to_original_position() -> void:
	position = Vector2.ZERO
#endregion
