extends PanelContainer

#region Declarations
# TODO: Replace with @onready when final design is made.
@export var item_directory : VBoxContainer
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
		item_directory.add_child(data_button)
#endregion
