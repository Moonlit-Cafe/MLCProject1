extends PanelContainer

#region Declarations
@onready var menu_actions : VBoxContainer = $MarginContainer/MenuActionsContainer
@onready var actions : VBoxContainer = $MarginContainer/ActionsContainer

var battle_scene : BaseEventScene
#endregion

#region Events
func _ready() -> void:
	battle_scene = find_parent("BattleScene")

func add_to_actions(ac: Action) -> void:
	var button := DataButton.new()
	button.data = ac
	actions.add_child(button)
	actions.move_child(button, 0)
	button.send_data.connect(_on_data_sent)
	button.text = ac.ac_name

func clear_menus() -> void:
	for child in actions.get_children():
		child.queue_free()
#endregion

#region Signal Callbacks
func _on_actions_menu_pressed() -> void:
	menu_actions.hide()
	actions.show()

func _on_return_pressed() -> void:
	menu_actions.show()
	actions.hide()

func _on_data_sent(data: Variant) -> void:
	if data is Action:
		CombatManager.selected_action = data
		battle_scene.battle_board.determine_selectables()
#endregion
