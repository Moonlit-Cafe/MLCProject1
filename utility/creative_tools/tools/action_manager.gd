extends Control

#region Declarations
@export var action_directory : VBoxContainer
@export var action_info : VBoxContainer
@export var shape_selector : PanelContainer
@export var shape_directory : VBoxContainer

var a_data : Dictionary[StringName, Variant] = {}
var shape_button : Button = null
#endregion

#region Events
func _ready() -> void:
	_load_actions()

func _load_actions() -> void:
	if not action_directory:
		return
	
	_clear_action_directory()
	
	for action_id in ResourceManager.action_compendium.keys():
		var button := DataButton.new()
		var action : CombatAction = ResourceManager.action_compendium.get(action_id)
		button.data = action
		button.text = action.ac_name
		button.send_data.connect(_on_action_pressed)
		action_directory.add_child(button)

func _clear_action_directory() -> void:
	for child in action_directory.get_children():
		action_directory.remove_child(child)
		child.queue_free()

func _load_info_panel(action: CombatAction) -> void:
	if not action_info:
		return
	
	_clear_action_info()
	
	a_data = action.get_manager_data().duplicate()
	for piece in a_data.keys():
		var control : Control = null
		var data = a_data.get(piece)
		if piece == &"id":
			control = Label.new()
			control.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			control.text = a_data.get(piece)
			_add_to_info(control)
		elif data is String or data is StringName:
			control = LineEdit.new()
			control.alignment = HORIZONTAL_ALIGNMENT_CENTER
			control.text = data
			_add_to_info(control)
		elif data is ActionShape:
			shape_button = Button.new()
			shape_button.name = "ShapeButton"
			shape_button.text = "ActionShape: %s" % data.shape_name
			shape_button.pressed.connect(_on_shape_pressed)
			_add_to_info(shape_button)
		elif data is AbilityCostPacket:
			control = CreativeUIGenerator.create_ability_cost_input()
			_add_to_info(control)
			control.set_data(data.CostType.keys(), data.cost_type, data.cost_amount)
		elif piece == &"damage_type":
			control = CreativeUIGenerator.create_enum_selector()
			_add_to_info(control)
			control.init(Genum.DamageType.keys(), data)
			control.text = "Damage Type"
		elif data is int:
			control = CreativeUIGenerator.create_int_field()
			_add_to_info(control)
			control.set_data(data)
			control.label_text = piece
		elif data is float:
			# TODO: Converge int and float into a general num field with a scale variable
			control = SpinBox.new()
			_add_to_info(control)
			control.value = data

func _add_to_info(control: Control) -> void:
	action_info.add_child(control)

func _clear_action_info() -> void:
	for child in action_info.get_children():
		action_info.remove_child(child)
		child.queue_free()

func _fill_shape_directory() -> void:
	if not shape_directory:
		return
	
	for child in shape_directory.get_children():
		shape_directory.remove_child(child)
		child.queue_free()
	
	for shape_id in ResourceManager.action_shape_compendium.keys():
		var button := DataButton.new()
		var shape : ActionShape = ResourceManager.action_shape_compendium.get(shape_id).duplicate()
		button.data = shape
		button.text = "%s: %s" % [shape_id, shape.shape_name]
		button.send_data.connect(_on_shape_selected)
		shape_directory.add_child(button)
#endregion

#region Signal Callbacks
func _on_action_pressed(data: Variant) -> void:
	if data is not CombatAction:
		return
	
	_load_info_panel(data)

func _on_return_pressed() -> void:
	if not shape_selector:
		return
	
	shape_selector.hide()

func _on_new_action_pressed() -> void:
	var new_action = CombatAction.new()
	new_action.ac_id = "ACT_%s" % ResourceManager.resource_count.get(&"Action")
	new_action.ac_name = "New Action"
	new_action.shape = ResourceManager.action_shape_compendium.get(&"ACS_0")
	ResourceManager.add_action(new_action)
	_load_info_panel(new_action)

func _on_save_pressed() -> void:
	# TODO: MaterialItem Specific data missing on save.
	if action_info.get_child_count() < 1:
		return
	
	var dmh := DataManipulationHelper.new()
	var action : CombatAction = ResourceManager.action_compendium.get(a_data.get(&"id"))
	var data_keys := a_data.keys()
	var idx : int = 0
	for child in action_info.get_children():
		if child is Label:
			idx += 1
			continue
		elif child is LineEdit:
			if data_keys.get(idx) == &"name":
				# TODO: Fix this up
				a_data.set(&"name", child.text)
				action.ac_name = a_data.get(&"name")
			a_data.set(data_keys.get(idx), child.text)
		elif child is SpinBox:
			a_data.set(data_keys.get(idx), child.value)
		else:
			if child is Button:
				if child.text.contains("ActionShape"):
					idx += 1
					continue
				if child.text == "Save Changes":
					continue
				if child.text == "Delete Item":
					continue
			a_data.set(data_keys.get(idx), child.get_data())
		idx += 1
	
	for key in a_data.keys():
		print("Encoding key [%s] with value %s" % [key, a_data.get(key)])
		a_data.set(key, dmh.encode_special_data(a_data.get(key)))
	
	print(a_data)
	action.load_data(a_data)
	ResourceManager.save_data()
	_clear_action_info()
	_load_actions()

func _on_delete_pressed() -> void:
	var action : Action = ResourceManager.action_compendium.get(a_data.get(&"id"))
	ResourceManager.remove_action(action)
	ResourceManager.save_data()
	_clear_action_info()
	_load_actions()

func _on_shape_pressed() -> void:
	if not shape_selector:
		return
	
	shape_selector.show()
	_fill_shape_directory()

func _on_shape_selected(data: Variant) -> void:
	if data is not ActionShape:
		return
	
	a_data.set(&"shape_id", data)
	if shape_button != null:
		shape_button.text = "ActionShape: %s" % data.shape_name
	_on_return_pressed()
#endregion
