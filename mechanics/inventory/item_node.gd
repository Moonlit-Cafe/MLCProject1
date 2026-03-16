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

#region Events
func _ready() -> void:
	# Initialize the item display
	update_display()
	# TODO: Connect to CraftManager for texture atlas
	# if item and CraftManager:
	#     icon = CraftManager.get_item_texture(item.texture)

## Initialize item display
func setup_item(new_item: Item, initial_count: int = 1) -> void:
	texture = $TextureRect
	item = new_item
	count = initial_count
	update_display()

# Update the visual display of the item
func update_display() -> void:
	if not item:
		queue_free()
		return
	
	# Set the icon from texture atlas
	if texture and item.texture != Vector2i.ZERO:
		texture.texture = CraftManager.get_item_texture(item.texture)
	
	# Update count displayi
	if count_label:
		count_label.text = str(count) if count > 1 else ""
		count_label.visible = count > 1

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
