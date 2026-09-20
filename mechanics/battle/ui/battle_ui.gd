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
	_setup_item_menu()
	
	_prep_move_player.connect(get_parent()._prep_tiles_move)
	_prep_atk_player.connect(get_parent()._prep_tiles_atk)
	
	
func _setup_ui() -> void:
	for child in get_children():
		if child is BattleMenu:
			child.setup()
	
func _setup_item_menu() -> void:
	return
	# TODO make the menu's actions load programatically
	# eg item menu should populate buttons based on actions from inventory
	# TYLER implement this
	# scan thru inventory
	# if item.action exists
	# create a button for it
	
func _highlight_menu(new_menu:BattleMenu) -> void:
	for child in get_children():
		if child is BattleMenu:
			child.visible = false
			
	new_menu.visible = true

func _flee() -> void:
	var battle_scene = get_parent().get_parent()
	battle_scene.get_parent().retreat()
	battle_scene.queue_free()
	# TODO implement this for real
	# should be a percentage, allowed to be effected by factors
	# should just boot player out to map
#endregion


#region Signal Callbacks
func load_action(pressed_action:BaseAction, pressed_menu:BattleMenu=null) -> void:
	if pressed_menu != null:
		_highlight_menu(pressed_menu)
		
		
	if pressed_action is AttackAction:
		return
	elif pressed_action is CombatAction:
		return
	elif pressed_action is BattleAction:
		return
	return
#endregion
