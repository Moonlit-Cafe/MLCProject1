class_name BattleButton extends Button

@export var button_action : BaseAction = null
@export var linked_menu : BattleMenu = null

@onready var battle_ui :BattleUI = get_parent().get_parent()

var action_name : StringName : 
	set(new):
		text = new
		action_name = new
		# TODO load a base action based on the given name
		# this is probably handled somewhere in global_resources.gd
		# var t = BaseAction.load_on_name(new)
		# button_action = t

func _ready() -> void:
	pressed.connect(battle_ui.button_pressed.bind(button_action, linked_menu))
