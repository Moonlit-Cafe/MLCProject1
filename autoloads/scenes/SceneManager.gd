# SceneManager.gd - Handles actual scene loading and transitions
class_name SceneManager
extends Node

var current_scene: Node
var prog_scene: ProgScene

@export var scene_paths = {
	"CraftScene": "res://scenes/CraftScene.tscn",
	"BattleScene": "res://scenes/BattleScene.tscn",
	"EliteBattleScene": "res://scenes/EliteBattleScene.tscn", 
	"BossScene": "res://scenes/BossScene.tscn",
	"ShopScene": "res://scenes/ShopScene.tscn",
	"UniqueEventScene": "res://scenes/UniqueEventScene.tscn"
}

func _ready():
	prog_scene = ProgScene.new()
	add_child(prog_scene)
	prog_scene.scene_changed.connect(_on_scene_changed)

func load_next_scene():
	var scene_data = prog_scene.generate_next_event()
	_load_scene(scene_data)

func _on_scene_changed(scene_type: String, scene_data: Dictionary):
	print("Scene changed to: ", scene_type, " with data: ", scene_data)

func _load_scene(scene_data: Dictionary):
	var scene_type = scene_data["scene_type"]
	
	if current_scene:
		current_scene.queue_free()
	
	# For now, create placeholder scenes
	current_scene = _create_placeholder_scene(scene_data)
	add_child(current_scene)

func _create_placeholder_scene(scene_data: Dictionary) -> Node:
	var scene = Control.new()
	scene.name = scene_data["scene_type"]
	
	var label = Label.new()
	label.text = "%s #%d\nData: %s" % [
		scene_data["scene_type"], 
		scene_data["scene_index"],
		str(scene_data)
	]
	label.position = Vector2(50, 50)
	scene.add_child(label)
	
	# Add a button to proceed to next scene
	var next_button = Button.new()
	next_button.text = "Next Scene"
	next_button.position = Vector2(50, 150)
	next_button.pressed.connect(load_next_scene)
	scene.add_child(next_button)
	
	return scene


# Example usage in main scene:
# func _ready():
#     var scene_manager = SceneManager.new()
#     add_child(scene_manager)
#     scene_manager.load_next_scene()
