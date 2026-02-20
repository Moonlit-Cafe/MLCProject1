extends PanelContainer

#region Declarations
# TODO: Replace with @onready when final design is made.
@export var item_directory : VBoxContainer
@export var info_container : VBoxContainer
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
#endregion

#region Signal Callbacks
func _on_data_pressed(data: Variant) -> void:
	if data is not Item:
		return
	
	for child in info_container.get_children():
		info_container.remove_child(child)
	
	var item_data : Dictionary[StringName, Variant] = data.get_manager_data()
	var dmh := DataManipulationHelper.new()
	for key in item_data.keys():
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		print(key)
		label.text = dmh.encode_special_data(item_data.get(key))
		info_container.add_child(label)
#endregion
