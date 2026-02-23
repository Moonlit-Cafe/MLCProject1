extends PanelContainer

#region Declarations
# TODO: Replace with @onready when final design is made.
@export var item_directory : VBoxContainer
@export var info_container : VBoxContainer

var i_data : Dictionary[StringName, Variant] = {}
#endregion

#region Events
func _ready() -> void:
	_load_data()

func _load_data() -> void:
	# Clears the directory
	for child in item_directory.get_children():
		item_directory.remove_child(child)
	
	for item_id in ResourceManager.item_compendium.keys():
		var data_button := DataButton.new()
		var item : Item = ResourceManager.item_compendium.get(item_id)
		data_button.text = item.i_name
		data_button.data = item
		data_button.send_data.connect(_on_data_pressed)
		item_directory.add_child(data_button)

func _clear_info() -> void:
	for child in item_directory.get_children():
		item_directory.remove_child(child)

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
	i_data = item_data

func _save_data_pressed() -> void:
	pass
#endregion
