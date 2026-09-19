class_name BattleMenu extends VBoxContainer

@export var is_base : bool = false
@export var source_menu : BattleMenu

var button_list : Array[String]

func setup() -> void:
	_define_list()
	_populate_menu()

func _define_list() -> void:
	if is_base:
		visible = true
		button_list = ["Attack", 
		"Move", 
		"Defend", 
		"Items", 
		"Other"]
	else:
		button_list.append("< Back")
# TODO make the menu's actions load programatically
		

## populate menu with buttons based on button_list
func _populate_menu() -> void:
	
	return
