class_name BattleMenu extends VBoxContainer

@export var is_base : bool = false

var button_list : Array[String]

func setup() -> void:
	_define_list()
	_populate_menu()
	set_anchors_preset(Control.LayoutPreset.PRESET_BOTTOM_LEFT)

func _define_list() -> void:
	if is_base:
		visible = true
		button_list = [
		"Attack", 
		"Move", 
		"Defend"]
		

## populate menu with buttons based on button_list
var y = 0
func _populate_menu() -> void:
	var new_button : BattleButton
	for button_text in button_list:
		new_button = BattleButton.new()
		new_button.text = button_text
		new_button.name = button_text
		
		self.add_child(new_button)
		move_child(new_button, y)
		y += 1
