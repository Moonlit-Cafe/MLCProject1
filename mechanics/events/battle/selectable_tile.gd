class_name SelectableTile extends Node2D

#region Declarations
@export var tile_highlight : Texture2D
@export var highlight_color : Color
@export var highlight_area : Node2D
@export var sprite : AnimatedSprite2D

var shape : ActionShape = null
var ref_enemies : Array = []
var selected : bool = false :
	set(value):
		if value:
			_check_selected()
			highlight_area.show()
			sprite.play("selected")
		else:
			highlight_area.hide()
			sprite.play("can_select")
		selected = value
#endregion

func _ready() -> void:
	add_to_group(&"select_tiles")

func generate_highlights(tile_size: int, bounds: Vector2) -> void:
	var shape_arr = shape.shape_pos_arr
	shape_arr.erase(Vector2i.ZERO)
	
	for point in shape_arr:
		if position.x + (point.x * tile_size) < bounds.x:
			continue
		elif position.x + (point.x * tile_size) > bounds.y:
			continue
		
		var highlight = Sprite2D.new()
		highlight.texture = tile_highlight
		highlight.modulate = highlight_color
		highlight.position = point * tile_size
		highlight_area.add_child(highlight)

func action_used(ac: Action) -> void:
	if not selected:
		return
	
	for enemy in ref_enemies:
		enemy.damage(ac)

func _check_selected() -> void:
	var tiles = get_tree().get_nodes_in_group(&"select_tiles")
	tiles.erase(self)
	for tile in tiles:
		if tile.selected:
			tile.selected = false

func _on_gui_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not event is InputEventMouseButton:
		return
	
	if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		selected = true
