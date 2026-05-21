extends PanelContainer

#region Declarations
@onready var menu_actions : VBoxContainer = $MenuContainers/MenuActionsContainer
@onready var actions : VBoxContainer = $MenuContainers/ActionsContainer
@onready var items : VBoxContainer = $MenuContainers/ItemsContainer
@onready var moves : VBoxContainer = $MenuContainers/MoveContainer

var battle_scene : BattleView
#endregion

#region Events
func _ready() -> void:
	battle_scene = find_parent("BattleView")
	$MenuContainers/MenuActionsContainer/Actions.grab_focus()
	
	CombatManager.use_action.connect(_on_used_action)

func _input(event: InputEvent) -> void:
	var focused_ui = get_viewport().gui_get_focus_owner()
	# TODO: We'll need to account for bottom and top button cases later
	
	if event.is_action_pressed(&"menu_up"):
		var next_focus = focused_ui.find_valid_focus_neighbor(SIDE_TOP)
		if next_focus:
			next_focus.grab_focus()
	elif event.is_action_pressed(&"menu_down"):
		var next_focus = focused_ui.find_valid_focus_neighbor(SIDE_BOTTOM)
		if next_focus:
			next_focus.grab_focus()
	elif event.is_action_pressed(&"menu_right") and menu_actions.visible:
		focused_ui.pressed.emit()
	elif event.is_action_pressed(&"menu_left") and not menu_actions.visible:
		_on_return_pressed()

func add_to_actions(ac: CombatAction) -> void:
	_create_new_button(actions, ac, ac.ac_name)

func add_to_items(usable: Usable) -> void:
	_create_new_button(items, usable, usable.us_name)

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

func _fill_action_menu() -> void:
	var act_comp = GameGlobal.resources.action_compendium
	PlayerManager.available_skills.append(act_comp.get(&"ACT_0")) # TODO: Remove later
	
	for action in PlayerManager.available_skills:
		add_to_actions(action)
	
	for usable in PlayerManager.get_usables():
		add_to_items(usable)
#endregion

#region Signal Callbacks
func _on_used_action() -> void:
	_on_return_pressed()
	CombatManager.rehover.emit()

func _on_actions_menu_pressed() -> void:
	menu_actions.hide()
	actions.show()
	actions.get_child(0).grab_focus()

func _on_items_menu_pressed() -> void:
	menu_actions.hide()
	items.show()
	items.get_child(0).grab_focus()

func _on_move_pressed() -> void:
	CombatManager.moving = true
	menu_actions.hide()
	moves.show()
	moves.get_child(0).grab_focus()
	
func _on_return_pressed() -> void:
	CombatManager.moving = false
	CombatManager.selected_action = null
	$MenuContainers/MenuActionsContainer/Actions.grab_focus()
	menu_actions.show()
	actions.hide()
	items.hide()
	moves.hide()
	battle_scene.battle_map.determine_selectables()
	

func _on_data_sent(data: Variant) -> void:
	if data is Usable:
		CombatManager.selected_action = data
		battle_scene.battle_map.determine_selectables()
	elif data is Action:
		CombatManager.selected_action = data
		battle_scene.battle_map.determine_selectables()
#endregion
