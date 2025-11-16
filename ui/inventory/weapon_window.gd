## Handles the window that allows implacing the components to a weapon upon a weapon.
extends PanelContainer

#region Declarations
@export var weapon_slot : InventorySlot

@onready var focus_slot : InventorySlot = $MarginContainer/VBoxContainer/FocusContainer/FocusSlot
@onready var frame_slot : InventorySlot = $MarginContainer/VBoxContainer/FrameContainer/FrameSlot
@onready var matrix_slot : InventorySlot = $MarginContainer/VBoxContainer/MatrixContainer2/MatrixSlot
#endregion

#region Events
func _ready() -> void:
	GameGlobalEvents.weapon_open.connect(_on_weapon_opened)
#endregion

#region Signal Callbacks
func _on_weapon_opened() -> void:
	if not weapon_slot.held_item:
		return
	
	var weapon = weapon_slot.held_item as WeaponNode
	
	if weapon.focus != null:
		focus_slot.add_child(weapon.focus)
		weapon.focus.position = Vector2.ZERO
	
	if weapon.frame != null:
		frame_slot.add_child(weapon.frame)
		weapon.frame.position = Vector2.ZERO
	
	if weapon.matrix != null:
		weapon.matrix.position = Vector2.ZERO
	
	show()

func _on_button_pressed() -> void:
	if not weapon_slot.held_item:
		return
	
	var weapon = weapon_slot.held_item as WeaponNode
	
	if focus_slot.held_item != null:
		weapon.focus = focus_slot.held_item
		focus_slot.remove_child(weapon.focus)
	else:
		if weapon.focus != null:
			weapon.focus = null
	
	if frame_slot.held_item != null:
		weapon.frame = frame_slot.held_item
		frame_slot.remove_child(weapon.frame)
	else:
		if weapon.frame != null:
			weapon.frame = null
	
	if matrix_slot.held_item != null:
		weapon.matrix = frame_slot.held_item
		matrix_slot.remove_child(weapon.matrix)
	else:
		if weapon.matrix != null:
			weapon.matrix = null
	
	hide()
#endregion
