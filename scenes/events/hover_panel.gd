extends VBoxContainer

@onready var container = $Subject/SubViewportContainer
@onready var title = $Subject/Label
@onready var description = $Text/Description
@onready var subinfo = $Text/SubLabel



func tile_hover(inc_tile : BattleTile = MouseHandler.hovered_tile):
	var entity:TileEntity = inc_tile.held_entity
	if not entity:
		return
		
	enable()

	var sprite = $Subject/Sprite
		
	if not sprite:
		sprite = Sprite2D.new()
		$Subject.add_child(sprite)
		
	sprite.sprite_frames = entity.sprite.sprite_frames.duplicate()
	sprite.position = Vector2.ZERO
	title.text = entity.character.o_name
	subinfo.text = str(inc_tile.tile_position)
	
	

func enable():
	visible = true
	self.position = get_global_mouse_position()


func disable():
	visible = false
