extends VBoxContainer

@onready var container = $Subject/SubViewportContainer
@onready var title = $Subject/Label
@onready var description = $Text/Description
@onready var subinfo = $Text/SubLabel



func tile_hover(inc_tile : BattleTile = MouseHandler.hovered_tile):
	#FIXME Panel back is now 100% Transparent
	var entity:TileEntity = inc_tile.held_entity
	if not entity:
		return

	_define_sprite(entity)
	
	#PLANNED have these populate based on the entity
	title.text = entity.character.o_name
	subinfo.text = str(inc_tile.tile_position)
	_define_description(entity)
	
	enable()

func _define_description(_entity):
	#TODO define the width based on the other elements' results
	description.text = "You can see this thing."
	
func _define_sprite(entity):
	#FIXME Sprite doesnt take the appropriate amount of space on the panel
	var sprite = $Subject/Sprite
	if not sprite:
		sprite = Sprite2D.new()
		$Subject.add_child(sprite)
		
	sprite.sprite_frames = entity.sprite.sprite_frames.duplicate()
	sprite.position = Vector2.ZERO
	

func enable():
	visible = true
	self.position = get_global_mouse_position()


func disable():
	visible = false
