# SceneManager.gd - Handles actual scene loading and transitions
extends Node

var prog_scene: ProgScene

@export var scene_paths : Dictionary[StringName, PackedScene] = {}

func load_next_scene():
	prog_scene.generate_next_events()
	PlayerManager.hp = PlayerManager.combat_stats.get(Genum.StatType.HEALTH)
