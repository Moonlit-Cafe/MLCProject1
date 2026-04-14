## The UI item for actual holding ItemNodes
class_name InventorySlot extends PanelContainer

#region Declarations
@export var can_slot : Genum.EquipLocation = Genum.EquipLocation.INVENTORY
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
@export var label : Label

signal check_set()

const ITEM_DEFAULT_SIZE = 72
#endregion

#region Events
func _ready() -> void:
	add_to_group(&"inv_slots")
	# NOTE: Consider adding visual feedback for slot state (empty/filled/hover)
	self.custom_minimum_size = Vector2.ONE * ITEM_DEFAULT_SIZE
	
	child_entered_tree.connect(_on_child_entered)
	child_exiting_tree.connect(_on_child_exited)

## Generates a new item based on the item id and the amount to generate.
func generate_item(item_id: StringName, count : int = 1) -> void:
	var node : ItemNode = CraftManager.generate_node(null, item_id)
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
		# TODO: Update visual state to show slot is filled
		# NOTE: Consider emitting a signal for inventory management
		
		if can_slot != Genum.EquipLocation.INVENTORY:
			check_set.emit()

func _on_child_exited(node: Node) -> void:
	if node == held_item:
		held_item = null
		
		if node is EquippableNode:
			check_set.emit()
			node.update_display()
		# TODO: Update visual state to show slot is empty
		# NOTE: Consider emitting a signal for inventory management

func _on_mouse_entered() -> void:
	print("Mouse Entered")
	MouseHandler.hovered_slot = self

func _on_mouse_exited() -> void:
	print("Mouse Exited")
	await GameGlobal.delay(0.3)
	if MouseHandler.hovered_slot == self:
		MouseHandler.hovered_slot = null
#endregion
