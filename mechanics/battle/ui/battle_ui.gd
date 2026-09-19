class_name BattleUI extends Node


signal _prep_move_player
signal _prep_atk_player

var menu
var other_menu
var item_menu

#region Events
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_ui()
	_setup_other_menu()
	_setup_item_menu()
	
	_prep_move_player.connect(get_parent()._prep_tiles_move)
	_prep_atk_player.connect(get_parent()._prep_tiles_atk)
	
	
func _setup_ui() -> void:
	for child in get_children():
		if child is BattleMenu:
			child.setup()
			
func _setup_menu() -> void:
	menu = get_child(0)
	
	var attack_button = menu.get_child(0)
	var move_button = menu.get_child(1)
	var other_button = menu.get_child(2)
	
	attack_button.pressed.connect(_prep_atk_player.emit)
	move_button.pressed.connect(_prep_move_player.emit)
	other_button.pressed.connect(_toggle_other)

func _setup_other_menu() -> void:
	other_menu = get_child(1)
	var flee = other_menu.get_child(0)
	var back = other_menu.get_child(1)
	
	flee.pressed.connect(_flee)
	back.pressed.connect(_toggle_other)
	
func _setup_item_menu() -> void:
	return
	# TODO implement this
	# scan thru inventory
	# if item.action exists
	# create a button for it
	
func _toggle_other() -> void:
	menu.visible = not menu.visible
	other_menu.visible = not other_menu.visible

func _flee() -> void:
	var battle_scene = get_parent().get_parent()
	battle_scene.get_parent().retreat()
	battle_scene.queue_free()
	# TODO implement this for real
	# should be a percentage, allowed to be effected by factors
	# should just boot player out to map
#endregion
