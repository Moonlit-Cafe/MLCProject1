extends PanelContainer

@onready var container = $VBoxContainer/Subject/Container
@onready var title = $VBoxContainer/Subject/Label
@onready var description = $VBoxContainer/Text/Description
@onready var subinfo = $VBoxContainer/Text/SubLabel



func tile_hover(inc_tile : BattleTile = MouseHandler.hovered_tile):
	var entity:TileEntity = inc_tile.held_entity
	if not entity:
		return
		
	enable()

	var sprite = container.get_child(0)
	
	sprite.replace_by(entity.sprite.duplicate())
	title.text = entity.character.o_name
	subinfo.text = str(inc_tile.tile_position)
	

func enable():
	visible = true
	self.position = get_global_mouse_position()


func disable():
	visible = false
