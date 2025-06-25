## The main component that will work alongside UI for dealing with items.
class_name ItemSlot extends Control

@export var current_item : ItemNode

func _process(_delta: float) -> void:
	if current_item:
		if not current_item.button_pressed:
			current_item.reparent(self)

func request_item_info() -> Item:
	if current_item:
		return current_item.item
	
	push_warning("There is no item currently in this slot")
	return null

func add_item(item_name: StringName) -> void:
	var item_info : Array = CraftManager.find_item(item_name)
	var item = ItemNode.new()
	item.item_set = item_info.get(0)
	item.item_tier = item_info.get(1)
	item.item = item_info.get(2)
	
	add_child(item)
	

func remove_item() -> void:
	for child in get_children():
		if child is ItemNode:
			child.queue_free()

func _on_resized() -> void:
	if size.length() > 2:
		$Area2D/CollisionShape2D.shape.size = size / 2
		$Area2D.position = size / 2
