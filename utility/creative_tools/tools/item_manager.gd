extends PanelContainer

#region Declarations
# TODO: Replace with @onready when final design is made.
@export var item_directory : VBoxContainer
@export var info_container : VBoxContainer
@export var add_item_button : Button
@export var item_choice_container : PanelContainer

var i_data : Dictionary[StringName, Variant] = {}
#endregion

#region Events
func _ready() -> void:
	_load_data()

func _load_data() -> void:
	# Clears the directory
	_clear_directory()
	
	for item_id in ResourceManager.item_compendium.keys():
		var data_button := DataButton.new()
		var item : Item = ResourceManager.item_compendium.get(item_id)
		data_button.text = item.i_name
		data_button.data = item
		data_button.send_data.connect(_on_data_pressed)
		item_directory.add_child(data_button)

func _clear_directory() -> void:
	for child in item_directory.get_children():
		item_directory.remove_child(child)

func _clear_info() -> void:
	for child in info_container.get_children():
		info_container.remove_child(child)
	
	i_data = {}

func _create_controls_from_data(item_data: Dictionary[StringName, Variant]) -> void:
	var dmh := DataManipulationHelper.new()
	for key in item_data.keys():
		var value = item_data.get(key)
		if value is Vector2i:
			var vec_field := CreativeUIGenerator.create_vector_field()
			info_container.add_child(vec_field)
			vec_field.set_data(item_data.get(key))
			continue
		elif value is int:
			if key == "material_type":
				var enum_select := CreativeUIGenerator.create_enum_selector()
				enum_select.init(Genum.MaterialType.keys(), value)
				info_container.add_child(enum_select)
				enum_select.text = key
				continue
			var int_field := CreativeUIGenerator.create_int_field()
			info_container.add_child(int_field)
			int_field.set_data(item_data.get(key))
			int_field.label_text = key
			continue
		elif value is Array[int]:
			var enum_field := CreativeUIGenerator.create_enum_array_field()
			enum_field.init(Genum.ItemTags.keys(), value)
			info_container.add_child(enum_field)
			enum_field.text = key
			continue
		elif (value is String or value is StringName) and key != "id":
			var line_edit := LineEdit.new()
			line_edit.text = value
			info_container.add_child(line_edit)
			continue
		
		# Assumes any other type is a string
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = dmh.encode_special_data(item_data.get(key))
		info_container.add_child(label)
	
#endregion

#region Signal Callbacks
func _on_data_pressed(data: Variant) -> void:
	if data is not Item:
		return
	
	for child in info_container.get_children():
		info_container.remove_child(child)
	
	var item_data : Dictionary[StringName, Variant] = data.get_manager_data()
	_create_controls_from_data(item_data)
	
	var save_button := Button.new()
	save_button.text = "Save Changes"
	info_container.add_child(save_button)
	var delete_button := Button.new()
	delete_button.text = "Delete Item"
	info_container.add_child(delete_button)
	
	save_button.pressed.connect(_save_data_pressed)
	delete_button.pressed.connect(_delete_data_pressed)
	i_data = item_data

func _save_data_pressed() -> void:
	# TODO: MaterialItem Specific data missing on save.
	var dmh := DataManipulationHelper.new()
	var item : Item = ResourceManager.item_compendium.get(i_data.get(&"id"))
	var data_keys := i_data.keys()
	var idx : int = 0
	for child in info_container.get_children():
		if child is Label:
			idx += 1
			continue
		elif child is LineEdit:
			if data_keys.get(idx) == &"name":
				# TODO: Fix this up
				i_data.set(&"name", child.text)
				item.i_name = i_data.get(&"name")
			i_data.set(data_keys.get(idx), child.text)
		else:
			if child is Button:
				if child.text == "Save Changes":
					continue
				if child.text == "Delete Item":
					continue
			i_data.set(data_keys.get(idx), child.get_data())
		idx += 1
	
	for key in i_data.keys():
		print("Encoding key [%s] with value %s" % [key, i_data.get(key)])
		i_data.set(key, dmh.encode_special_data(i_data.get(key)))
	
	print(i_data)
	item.load_data(i_data)
	ResourceManager.save_data()
	_clear_info()
	_load_data()

func _delete_data_pressed() -> void:
	if i_data.get("id") in ResourceManager.item_compendium:
		ResourceManager.remove_item(i_data.get("id"))
	i_data = {}
	ResourceManager.save_data()
	_clear_info()
	_load_data()

func _add_item_pressed() -> void:
	item_choice_container.show()

func _material_item_pressed() -> void:
	var material_count : int = ResourceManager.get_data_count(ResourceManager.DataType.ITEM,
		ResourceManager.ItemType.MATERIAL)
	var item := MaterialItem.new()
	item.id = &"MAT_%s" % material_count
	item.i_name = "New Material %s" % material_count
	ResourceManager.item_compendium.set(item.id, item)
	_on_data_pressed(item)
	item_choice_container.hide()

func _usable_item_pressed() -> void:
	item_choice_container.hide()

func _equip_item_pressed() -> void:
	item_choice_container.hide()

func _weapon_item_pressed() -> void:
	item_choice_container.hide()

func _cancel_button_pressed() -> void:
	item_choice_container.hide()
#endregion
