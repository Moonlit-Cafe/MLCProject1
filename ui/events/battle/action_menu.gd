extends PanelContainer

#region Declarations
@onready var menu_actions : VBoxContainer = $MenuContainers/MenuActionsContainer
@onready var actions : VBoxContainer = $MenuContainers/ActionsContainer
@onready var items : VBoxContainer = $MenuContainers/ItemsContainer
@onready var moves : VBoxContainer = $MenuContainers/MoveContainer

var battle_scene : BaseEventScene
#endregion

#region Events
func _ready() -> void:
	battle_scene = find_parent("BattleScene")

func add_to_actions(ac: Action) -> void:
	_create_new_button(actions, ac, ac.ac_name)

func add_to_items(usable: ItemNode) -> void:
	_create_new_button(items, usable, usable.item.i_name)

func clear_menu(menu: VBoxContainer) -> void:
	for child in menu.get_children():
		if child.text == "Back":
			continue
		child.queue_free()

func clear_menus() -> void:
	clear_menu(actions)
	clear_menu(items)

func _create_new_button(menu: VBoxContainer, data: Variant, text: String) -> void:
	var button := DataButton.new()
	button.data = data
	menu.add_child(button)
	menu.move_child(button, 0)
	button.send_data.connect(_on_data_sent)
	button.text = text
#endregion

#region Signal Callbacks
func _on_actions_menu_pressed() -> void:
	menu_actions.hide()
	actions.show()

func _on_items_menu_pressed() -> void:
	menu_actions.hide()
	items.show()

func _on_move_pressed() -> void:
	menu_actions.hide()
	moves.show()
	
func _on_return_pressed() -> void:
	menu_actions.show()
	actions.hide()
	items.hide()
	moves.hide()
	

func _on_data_sent(data: Variant) -> void:
	if data is Action:
		CombatManager.selected_action = data
		battle_scene.battle_board.determine_selectables()
	elif data is ItemNode:
		print("Using item ", data.item.i_name, " . . . Unsuccessful. Try again next update.")
		data.count -= 1
		clear_menu(items)
		for usable in PlayerManager.get_usables():
			add_to_items(usable)
#endregion
