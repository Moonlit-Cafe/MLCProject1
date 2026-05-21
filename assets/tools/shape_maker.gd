@tool
class_name ShapeMaker extends Control

const GRID_SIZE : int = 5
const HALF_SPAN : int = GRID_SIZE / 2
const TILE_SIZE : Vector2 = Vector2(56, 56)

@export_file("*.json") var shapes_file : String = "res://assets/data/attack_shapes.json"
@export var default_range : int = 3

@export var tile_grid : GridContainer
@export var shape_name_input : LineEdit
@export var range_input : SpinBox
@export var save_button : Button
@export var clear_button : Button
@export var new_shape_button : Button
@export var status_label : Label
@export var source_label : Label

@export var shapes_list : ItemList
@export var move_up_button : Button
@export var move_down_button : Button
@export var delete_button : Button

var tile_buttons : Dictionary = {}
var selected_tiles : Dictionary = {}
var source_tile : Vector2i = Vector2i.ZERO
var shapes_cache : Dictionary = {}
var shape_ids : Array[String] = []

func _ready() -> void:
	range_input.value = default_range
	if tile_grid.get_child_count() == 0:
		_build_grid()
	_select_tile(Vector2i.ZERO, true)
	_set_source(Vector2i.ZERO)
	shapes_cache = _load_existing_shapes()
	_refresh_shape_list()
	
	if shapes_list:
		shapes_list.item_selected.connect(_on_shape_item_selected)
	save_button.pressed.connect(_save_shape)
	clear_button.pressed.connect(_clear_grid)
	if new_shape_button:
		new_shape_button.pressed.connect(_new_shape)
	
	if move_up_button:
		move_up_button.pressed.connect(func() -> void:
			_move_selected_shape(-1)
		)
	if move_down_button:
		move_down_button.pressed.connect(func() -> void:
			_move_selected_shape(1)
		)
	if delete_button:
		delete_button.pressed.connect(_delete_selected_shape)
	
	status_label.text = "Ready to build a shape."

func _build_grid() -> void:
	tile_grid.columns = GRID_SIZE
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var coord : Vector2i = Vector2i(x - HALF_SPAN, HALF_SPAN - y)
			var tile : Button = Button.new()
			tile.toggle_mode = true
			tile.focus_mode = Control.FOCUS_NONE
			tile.custom_minimum_size = TILE_SIZE
			tile.text = ""
			tile.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			tile_gui_input_setup(tile, coord)
			tile_grid.add_child(tile)
			tile_buttons[coord] = tile
			_update_tile_visual(coord)

func tile_gui_input_setup(tile: Button, coord: Vector2i) -> void:
	tile.gui_input.connect(func(event: InputEvent) -> void:
		if not event is InputEventMouseButton:
			return
		
		var mouse_event : InputEventMouseButton = event as InputEventMouseButton
		if not mouse_event.pressed:
			return
		
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.shift_pressed:
			_select_tile(coord, true)
			_set_source(coord)
			return
		
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			var currently_selected : bool = selected_tiles.has(coord)
			_select_tile(coord, not currently_selected)
			return
		
		if mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			if coord == source_tile:
				_set_status("Cannot deselect the source tile. Choose another source first.")
				return
			_select_tile(coord, false)
			return
	)

func _select_tile(coord: Vector2i, pressed: bool) -> void:
	if not tile_buttons.has(coord):
		return
	
	var button : Button = tile_buttons[coord] as Button
	button.button_pressed = pressed
	if pressed:
		selected_tiles[coord] = true
	else:
		selected_tiles.erase(coord)
	
	_update_tile_visual(coord)

func _set_source(coord: Vector2i) -> void:
	source_tile = coord
	if not selected_tiles.has(coord):
		_select_tile(coord, true)
	
	for tile_coord in tile_buttons.keys():
		_update_tile_visual(tile_coord)
	
	_update_source_display()
	_set_status("Source updated to (%d, %d)." % [coord.x, coord.y])

func _update_tile_visual(coord: Vector2i) -> void:
	var button : Button = tile_buttons.get(coord, null) as Button
	if not button:
		return
	
	var is_selected : bool = selected_tiles.has(coord)
	if coord == source_tile:
		button.text = "S"
		button.add_theme_color_override("font_color", Color(0.96, 0.84, 0.36))
		button.button_pressed = true
	elif is_selected:
		button.text = "X"
		button.add_theme_color_override("font_color", Color(0.8, 0.95, 1.0))
	else:
		button.text = ""
		button.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
		button.button_pressed = false

func _update_source_display() -> void:
	source_label.text = "Source tile: (%d, %d)" % [source_tile.x, source_tile.y]

func _clear_grid() -> void:
	_clear_tiles_only()
	_select_tile(Vector2i.ZERO, true)
	_set_source(Vector2i.ZERO)
	range_input.value = default_range
	shape_name_input.clear()
	_set_status("Grid reset.")

func _clear_tiles_only() -> void:
	selected_tiles.clear()
	for coord in tile_buttons.keys():
		_select_tile(coord, false)

func _new_shape() -> void:
	_clear_grid()
	if shapes_list:
		shapes_list.deselect_all()
	_set_status("Started a new shape.")

func _save_shape() -> void:
	var shape_name : String = shape_name_input.text.strip_edges()
	if shape_name.is_empty():
		_set_status("Shape name cannot be empty.")
		return
	
	if selected_tiles.is_empty():
		_set_status("Select at least one tile.")
		return
	
	if not selected_tiles.has(source_tile):
		_set_status("Source tile must be part of the shape.")
		return
	
	var serialized_points : Array = _serialize_points()
	if serialized_points.is_empty():
		_set_status("Failed to serialize shape points.")
		return
	
	var range_value : int = int(range_input.value)
	shapes_cache[shape_name] = {
		"id": shape_name,
		"range": range_value,
		"positions": serialized_points
	}
	
	if _write_shapes():
		# Reload from disk to ensure we're in sync with the JSON file.
		shapes_cache = _load_existing_shapes()
		_refresh_shape_list()
		if shapes_list:
			var idx : int = shape_ids.find(shape_name)
			if idx != -1:
				shapes_list.select(idx)
		_set_status("Shape '%s' saved." % shape_name)
	else:
		_set_status("Failed to write to %s" % shapes_file)

func _serialize_points() -> Array:
	var points : Array = []
	for coord in selected_tiles.keys():
		var relative : Vector2i = coord - source_tile
		points.append(relative)
	
	points.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		if a.y == b.y:
			return a.x < b.x
		return a.y > b.y
	)
	
	var serialized : Array = []
	for point in points:
		serialized.append([point.x, point.y])
	
	return serialized

func _refresh_shape_list() -> void:
	if not shapes_list:
		return
	
	shapes_list.clear()
	shape_ids.clear()
	
	for key in shapes_cache.keys():
		var id : String = str(key)
		shape_ids.append(id)
	
	for id in shape_ids:
		shapes_list.add_item(id)

func _on_shape_item_selected(index: int) -> void:
	_load_shape_by_index(index)

func _load_shape_by_index(index: int) -> void:
	if index < 0 or index >= shape_ids.size():
		return
	
	var id : String = shape_ids[index]
	if not shapes_cache.has(id):
		return
	
	var data : Dictionary = shapes_cache[id]
	var positions : Array = data.get("positions", [])
	var range_value : int = int(data.get("range", default_range))
	
	_clear_tiles_only()
	_set_source(Vector2i.ZERO)
	
	for p in positions:
		if not (p is Array) or p.size() < 2:
			continue
		var rel : Vector2i = Vector2i(int(p[0]), int(p[1]))
		var coord : Vector2i = source_tile + rel
		if tile_buttons.has(coord):
			_select_tile(coord, true)
	
	range_input.value = range_value
	shape_name_input.text = id
	_set_status("Loaded shape '%s'." % id)

func _move_selected_shape(direction: int) -> void:
	if not shapes_list:
		return
	var selected_indices := shapes_list.get_selected_items()
	if selected_indices.is_empty():
		return
	
	var index : int = selected_indices[0]
	var new_index : int = index + direction
	if new_index < 0 or new_index >= shape_ids.size():
		return
	
	var id : String = shape_ids[index]
	shape_ids.remove_at(index)
	shape_ids.insert(new_index, id)
	
	# Rebuild list UI in new order.
	shapes_list.clear()
	for sid in shape_ids:
		shapes_list.add_item(sid)
	shapes_list.select(new_index)
	_set_status("Reordered shapes.")

func _delete_selected_shape() -> void:
	if not shapes_list:
		return
	var selected_indices := shapes_list.get_selected_items()
	if selected_indices.is_empty():
		return
	
	var index : int = selected_indices[0]
	if index < 0 or index >= shape_ids.size():
		return
	
	var id : String = shape_ids[index]
	shape_ids.remove_at(index)
	shapes_cache.erase(id)
	
	_refresh_shape_list()
	_clear_grid()
	_set_status("Deleted shape '%s'." % id)

func _load_existing_shapes() -> Dictionary:
	if not FileAccess.file_exists(shapes_file):
		return {}
	
	var data_text : String = FileAccess.get_file_as_string(shapes_file)
	if data_text.is_empty():
		return {}
	
	var parsed : Variant = JSON.parse_string(data_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	
	return parsed

func _write_shapes() -> bool:
	# Ensure shapes are written in the current order.
	if not shape_ids.is_empty():
		var ordered : Dictionary = {}
		for id in shape_ids:
			if shapes_cache.has(id):
				ordered[id] = shapes_cache[id]
		for extra_id in shapes_cache.keys():
			if not shape_ids.has(str(extra_id)):
				var key_str : String = str(extra_id)
				shape_ids.append(key_str)
				ordered[key_str] = shapes_cache[extra_id]
		shapes_cache = ordered
	
	var file : FileAccess = FileAccess.open(shapes_file, FileAccess.WRITE)
	if file == null:
		return false
	
	file.store_string(JSON.stringify(shapes_cache, "\t"))
	return true

func _set_status(text: String) -> void:
	status_label.text = text
