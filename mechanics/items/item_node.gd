## An extension of Button to specifically act as the items for an inventory.
class_name ItemNode extends TextureButton

@export var item_set : ItemSet
@export var item_tier : Genum.ItemTier = Genum.ItemTier.MUNDANE

# TODO: Item stacking

var areas : Array[Area2D]

var item : Item
#var hovering := false
#var dragging := false

# TODO (Low): Little animation while dragging.

func _ready() -> void:
	if item_set != null:
		item = item_set.item_set.get(item_tier)
		texture_normal = CraftManager.get_item_texture(item.item_texture)
	
	button_up.connect(_on_button_released)

func _process(_delta: float) -> void:
	if button_pressed:
		global_position = get_global_mouse_position()

func _on_button_released() -> void:
	GameGlobalEvents.stop_dragging.emit()
	var parent_area : Area2D
	for area in areas:
		if not parent_area:
			parent_area = area
		else:
			if global_position.direction_to(area.global_position) < global_position.direction_to(area.global_position):
				parent_area = area
	
	if parent_area:
		if parent_area.owner is ItemSlot:
			for child in parent_area.owner.get_children():
				if child is ItemNode:
					position = Vector2.ZERO
					return
		
		reparent(parent_area.owner)
		parent_area.owner.current_item = self
	
	position = Vector2.ZERO

func _on_area_entered(area: Area2D) -> void:
	areas.append(area)

func _on_area_exited(area: Area2D) -> void:
	areas.erase(area)
