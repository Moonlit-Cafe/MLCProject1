class_name BattleManager extends Node

signal _prep_move_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_child(0).get_child(1).pressed.connect(_prep_move_player.emit)
