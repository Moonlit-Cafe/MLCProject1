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
	
func _setup_ui():
	UI = get_child(0)
	
	var attack_button = UI.get_child(0)
	var move_button = UI.get_child(1)
	var other_button = UI.get_child(2)
	
	attack_button.pressed.connect(_prep_atk_player.emit)
	move_button.pressed.connect(_prep_move_player.emit)
	other_button.pressed.connect(_other_ui)

func _setup_other_ui():
	other_UI = get_child(1)
	var flee = other_UI.get_child(0)
	var back = other_UI.get_child(1)
	
	#flee.pressed.connect()
	back.connect("pressed", )
	back.pressed.connect(_other_ui, false)
	
func _other_ui(enable = true):
	
	UI.visible = not enable
	other_UI.visible = enable

#endregion
	
	
