## An extension of Button to specifically act as the items for an inventory.
class_name ItemNode extends Area2D

@export var item_set : ItemSet
@export var item_tier : Genum.ItemTier = Genum.ItemTier.MUNDANE

var item : Item
var hovering := false
var dragging := false

# TODO (Low): Little animation while dragging.

func _ready() -> void:
	if item_set != null:
		item = item_set.item_set.get(item_tier)
		$Sprite2D.texture = CraftManager.get_item_texture(item.item_texture)

func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if hovering:
		if not dragging:
			if event.is_action_pressed(&"mouse_action"):
				dragging = true
		elif event.is_action_released(&"mouse_action"):
			dragging = false
	elif dragging:
		if event.is_action_released(&"mouse_action"):
			dragging = false
			GameGlobalEvents.stop_dragging.emit()

func _on_mouse_entered() -> void:
	hovering = true

func _on_mouse_exited() -> void:
	hovering = false
