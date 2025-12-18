class_name Player extends Node2D

func _ready() -> void:
	SceneManager.battle_map.register_player(self)
