# SceneManager.gd - Handles actual scene loading, transitioning, and managing data between scenes
extends Node

var prog_scene: ProgScene

@export var scene_paths : Dictionary[StringName, PackedScene] = {}
var battle_map : BattleMap

func load_next_scene():
	prog_scene.generate_next_events()
