class_name BattleManager extends Node

signal _prep_move_player
signal _prep_atk_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var UI = get_child(0)
	var attack_button = UI.get_child(0)
	var move_button = UI.get_child(1)
	
	attack_button.pressed.connect(_prep_atk_player.emit)
	move_button.pressed.connect(_prep_move_player.emit)
	
