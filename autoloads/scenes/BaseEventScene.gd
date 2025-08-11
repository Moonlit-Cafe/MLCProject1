# BaseEventScene.gd - Base class for all event scenes
class_name BaseEventScene
extends Control

var scene_data: Dictionary
signal scene_completed(result: Dictionary)

func initialize(data: Dictionary):
	scene_data = data
	setup_scene()

func setup_scene():
	# Override in derived classes
	pass

func complete_scene(result: Dictionary = {}):
	scene_completed.emit(result)