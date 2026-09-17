class_name BattleMenu extends VBoxContainer

@export var button_list : Array[String]
@export var is_base : bool = false
@export var source_menu : BattleMenu

## populate menu with buttons based on button_list
func setup() -> void:
	if is_base:
		visible = true
		button_list = ["Attack", 
		"Move", 
		"Defend", 
		"Items", 
		"Other"]
	else:
		button_list.append("< Back")
		
	
