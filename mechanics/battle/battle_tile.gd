## Houses all the functionality for the tiles that TileEntities stand on.
class_name BattleTile extends Node3D

#region Declarations
var area : Area3D
#endregion

#region Events
static func generate_battle_tile(tile_name: StringName=&"NewTile") -> BattleTile:
	var new_tile := BattleTile.new()
	new_tile.name = tile_name
	
	var click_area := Area3D.new()
	new_tile.area = click_area
	var click_col := CollisionShape3D.new()
	var click_pane := BoxShape3D.new()
	click_pane.size = Vector3(1, 0.1, 1)
	click_col.shape = click_pane
	click_area.add_child(click_col)
	new_tile.add_child(click_area)
	click_area.position = Vector3(0, -0.5, 0) # TODO: Replace all magic numbers with a Global reference
	# to standard tile size.
	
	return new_tile

func _ready() -> void:
	_init_signals()

func _init_signals() -> void:
	area.input_event.connect(_on_input_event)
#endregion

#region Signal Callbacks
func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if not (event is InputEventMouseButton):
		return
	
	if event.is_action(&"cam_pan"):
		return
	
	if not event.is_released():
		return
	
	Global.logs.post_message(self, "I've been clicked.")
#endregion
