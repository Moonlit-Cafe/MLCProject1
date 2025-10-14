## The UI item for actual holding ItemNodes
class_name InventorySlot extends PanelContainer

@export var item_node : PackedScene
@export var can_slot : Genum.EquipLocation = Genum.EquipLocation.INVENTORY
var inv_position := Vector2i.ZERO
var held_item : ItemNode = null :
	set(value):
		if can_slot != Genum.EquipLocation.INVENTORY:
			if held_item:
				if held_item.item in PlayerManager.equipped_items:
					PlayerManager.equipped_items.erase(held_item.item)
			
			if value:
				PlayerManager.equipped_items.append(value.item)
			PlayerManager.regen_combat_stats()
		
		held_item = value
var hovered_item : ItemNode = null

#region Built-Ins
func _ready() -> void:
	add_to_group(&"inv_slots")
	# NOTE: Consider adding visual feedback for slot state (empty/filled/hover)
	# TODO: Add slot type restrictions if needed (e.g., equipment slots)
	
	# Connect to child node changes to track held_item
	child_entered_tree.connect(_on_child_entered)
	child_exiting_tree.connect(_on_child_exited)
#endregion

#region Item Handling
func generate_item(i_name: StringName, count : int = 1) -> void:
	var node : ItemNode = item_node.instantiate()
	node.item = CraftManager.find_item(i_name.to_snake_case())
	print(node.item.i_name)
	node.count = count
	add_child(node)
	held_item = node

# Handle item combining logic
func can_combine_with(other_item: ItemNode) -> bool:
	if held_item == null or other_item == null:
		return false
	
	# Items can combine if they're the same type
	return held_item.item.id == other_item.item.id

# Attempt to combine items, returns true if successful
func try_combine(other_item: ItemNode) -> bool:
	var overflow = held_item.add_to_stack(other_item.count)
	if overflow > 0:
		other_item.count = overflow
		return false
	return true
#endregion

#region Slot Handling
func is_close(pos: Vector2) -> bool:
	if global_position.distance_to(pos) < size.length():
		return true
	else:
		return false

## Check if slot is empty
func is_empty() -> bool:
	return held_item == null

# Get the item without removing it
func peek_item() -> ItemNode:
	return held_item
#endregion

#region Signal Callbacks
# Track when items are added/removed
func _on_child_entered(node: Node) -> void:
	if node is ItemNode:
		held_item = node as ItemNode
		if held_item == hovered_item:
			hovered_item = null
		# TODO: Update visual state to show slot is filled
		# NOTE: Consider emitting a signal for inventory management

func _on_child_exited(node: Node) -> void:
	if node == held_item:
		held_item = null
		# TODO: Update visual state to show slot is empty
		# NOTE: Consider emitting a signal for inventory management
#endregion
