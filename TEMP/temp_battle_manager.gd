class_name BattleManager extends Node

signal _prep_move_player
signal _prep_atk_player

var UI
var other_UI

#region Events
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_ui()
	_setup_other_ui()
	
func _setup_ui() -> void:
	UI = get_child(0)
	
	var attack_button = UI.get_child(0)
	var move_button = UI.get_child(1)
	var other_button = UI.get_child(2)
	
	attack_button.pressed.connect(_prep_atk_player.emit)
	move_button.pressed.connect(_prep_move_player.emit)
	other_button.pressed.connect(_toggle_other)

func _setup_other_ui() -> void:
	other_UI = get_child(1)
	var flee = other_UI.get_child(0)
	var back = other_UI.get_child(1)
	
	flee.pressed.connect(_flee)
	back.pressed.connect(_toggle_other)
	
func _toggle_other() -> void:
	UI.visible = not UI.visible
	other_UI.visible = not other_UI.visible

func _flee() -> void:
	# TODO implement this real
	# should be a percentage, allowed to be effected by factors
	# should just boot player out to map
	var t = get_parent().get_parent()
	t.queue_free()
	t.get_parent().init_battle()
#endregion
	
	
