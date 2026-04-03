## Handles everything related to the Mouse and possibly allow this to be controlled by both an
## actual mouse but also with keyboard or gamepad if lacking a mouse.
extends Node2D

#region Declarations
@onready var container : InventorySlot = $ItemContainer

# Variables for inventory handling
var prior_slot : InventorySlot
var hovered_slot : InventorySlot
# Variables for combat handling
var selected_tile : BattleTile
var hovered_tile : BattleTile
#endregion

# TODO: There seems to be some problem with the mouse that causes it to not register
# input for a recently _moved_to_hovered action.

# TODO: Come back so that I can add Item Splitting Fuctionality
#region Events
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if hovered_slot is ShopSlot:
			hovered_slot.attempt_purchase()
		else:
			_inventory_handling(event)

## Handles all the inventory handling code for input.
func _inventory_handling(event: InputEventMouseButton) -> void:
	if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if event.pressed and hovered_slot:
			# TODO: Come back to this . . . I dunno what is going on.
			if not hovered_slot.is_empty():
				if not container.held_item:
					_move_to_container()
				else:
					_move_to_prior()
					#_move_to_container()
		elif not event.pressed and container.held_item:
			if not hovered_slot:
				_move_to_prior()
				return
			else:
				if not hovered_slot.is_empty():
					if hovered_slot.held_item.item == container.held_item.item:
						var leftover = hovered_slot.held_item.add_to_stack(container.held_item.count)
						var previous_item = container.held_item
						
						if leftover:
							var t = hovered_slot.can_slot != Genum.EquipLocation.INVENTORY
							container.held_item.count = leftover
							_move_to_prior()
							if t:
								hovered_slot.check_set.emit()
						else:
							previous_item.queue_free()
						
						container.held_item = null
						
					else:
						_switch_with_hovered()
				else:
					_move_to_hovered()
	
	if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
		if event.pressed and hovered_slot:
			if hovered_slot.can_slot == Genum.EquipLocation.WEAPON:
				if hovered_slot.held_item != null:
					GameGlobalEvents.weapon_open.emit()

func _move_to_hovered() -> void:
	var item_to_move : ItemNode = container.held_item
	
	if hovered_slot.can_slot != Genum.EquipLocation.INVENTORY:
			if item_to_move.item.equip_loc != hovered_slot.can_slot:
				_move_to_prior()
				return 
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

func _switch_with_hovered() -> void:
	var item_to_switch : ItemNode = container.held_item
	var switched_item : ItemNode = hovered_slot.held_item
	container.remove_child(item_to_switch)
	hovered_slot.remove_child(switched_item)
	
	hovered_slot.add_child(item_to_switch)
	prior_slot.add_child(switched_item)
	
	prior_slot = null
	item_to_switch.position = Vector2.ZERO
	switched_item.position = Vector2.ZERO
#endregion

#region Processes
func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
#endregion
