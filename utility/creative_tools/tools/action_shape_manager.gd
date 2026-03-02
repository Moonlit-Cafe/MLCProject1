extends PanelContainer

#region Declarations
@export var action_directory : VBoxContainer
@export var shape_grid : GridContainer

const SHAPE_SIZE : int = 7

var offset : int = 0
var vector_list : Array[Vector2i] = []
#endregion

#region Events
func _ready() -> void:
	offset = int(floor(SHAPE_SIZE / 2.))
	
	_load_shapes()
	_generate_grid()

func _load_shapes() -> void:
	if not action_directory:
		push_warning("@ActionShapeManager: No action_directory connected...")
		return
	
	for shape in ResourceManager.action_shape_compendium.keys():
		var data_button := DataButton.new()
		var action_shape : ActionShape = ResourceManager.action_shape_compendium.get(shape)
		data_button.data = action_shape
		data_button.text = action_shape.shape_name
		data_button.send_data.connect(_on_data_button_pressed)
		action_directory.add_child(data_button)

func _generate_grid() -> void:
	if not shape_grid:
		push_warning("@ActionShapeManager: No shape_grid connected...")
		return
	
	for x in range(SHAPE_SIZE):
		for y in range(SHAPE_SIZE):
			var pos_button := Button.new()
			var pos := Vector2i(x - offset, y - offset)
			pos_button.toggle_mode = true
			pos_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			pos_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
			pos_button.toggled.connect(_on_grid_button_pressed.bind(pos, pos_button))
			shape_grid.add_child(pos_button)

func _add_to_grid(ac_shape: ActionShape) -> void:
	vector_list = []
	
	for child in shape_grid.get_children():
		if child.button_pressed:
			child.button_pressed = false
	
	for pos in ac_shape.shape_pos_arr:
		var idx = (pos.x + offset) + (pos.y + offset) * SHAPE_SIZE
		var button : Button = shape_grid.get_child(idx)
		button.button_pressed = true
#endregion

#region Helpers
func _sort_vectors(a: Vector2i, b: Vector2i) -> bool:
	if a.y < b.y:
		return true
	elif a.y == b.y:
		if a.x < b.x:
			return true
	
	return false
#endregion

#region Signal Callbacks
func _on_data_button_pressed(data: Variant) -> void:
	if data is not ActionShape:
		print(data)
		return
	
	_add_to_grid(data)

func _on_grid_button_pressed(toggled_on: bool, pos: Vector2i, _button: Button) -> void:
	if not toggled_on:
		vector_list.erase(pos)
		return
	
	vector_list.append(pos)
	vector_list.sort_custom(_sort_vectors)
#endregion
