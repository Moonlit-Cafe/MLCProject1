extends PanelContainer

@onready var sprite = $VBoxContainer/Subject/Sprite
@onready var title = $VBoxContainer/Subject/Label
@onready var description = $VBoxContainer/Text/Description
@onready var subinfo = $VBoxContainer/Text/SubLabel



func tile_hover(inc_tile : BattleTile = MouseHandler.hovered_tile):
	_toggle()

	var entity:TileEntity = inc_tile.held_entity
	if not entity:
		return
	sprite = entity.sprite
	title = entity.character.o_name
	subinfo.text = str(inc_tile.tile_position)
	

func _toggle():
	visible = not visible
	
	if not visible:
		return
		
	self.position = get_global_mouse_position()
