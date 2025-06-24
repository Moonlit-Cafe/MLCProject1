## The main component that will work alongside UI for dealing with items.
class_name ItemSlot extends Node2D

@export var current_item : ItemNode

# TODO: Items need to reset to their current slot if placed in an empty space

func _process(_delta: float) -> void:
	if current_item:
		if not current_item.dragging:
			current_item.reparent(self)
			current_item.position = Vector2.ZERO

func _on_area_entered(area: Area2D) -> void:
	if area.owner is ItemNode:
		if not current_item:
			current_item = area.owner
		elif current_item != area.owner:
			area.owner.position = Vector2.ZERO

func _on_area_exited(area: Area2D) -> void:
	if area.owner == current_item:
		current_item = null
