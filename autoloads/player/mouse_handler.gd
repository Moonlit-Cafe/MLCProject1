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
#endregion

# TODO: There seems to be some problem with the mouse that causes it to not register
# input for a recently _moved_to_hovered action.

# TODO: Come back so that I can add Item Splitting Fuctionality
#region Events
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_inventory_handling(event)
		_combat_tile_handling(event)

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
						hovered_slot.held_item.add_to_stack(container.held_item.count)
						var previous_item = container.held_item
						container.held_item = null
						previous_item.queue_free()
					else:
						_switch_with_hovered()
				else:
					_move_to_hovered()
	pass

func _combat_tile_handling(event: InputEventMouseButton) -> void:
	if not CombatManager.player_turn:
		return
	
	if event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and not selected_tile:
		GameGlobalEvents.battle_tile_selected.emit()
	elif event.double_click and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		GameGlobalEvents.attack_tile.emit()
	elif event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
		var prev_tile = selected_tile
		selected_tile = null
		prev_tile.refresh_highlight()

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
