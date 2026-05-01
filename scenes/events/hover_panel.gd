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
	#TODO define the width of this control from the other elements' results
	description.text = "You can see this thing."
	
func _define_sprite(entity):
	var sprite = $Subject/MarginContainer/Sprite
	sprite.sprite_frames = entity.sprite.sprite_frames.duplicate()
	sprite.position = Vector2.ZERO
	
	# HACK ugly, look for more elegant implementation
	# FIXME crashes here from battle scene
	# Something to do with hovering over a null panel, probably?
	$Subject/MarginContainer.add_theme_constant_override("margin_right", sprite.sprite_frames.get_frame_texture(sprite.animation, 0).get_width()*2)
	$Subject/MarginContainer.add_theme_constant_override("margin_bottom", sprite.sprite_frames.get_frame_texture(sprite.animation, 0).get_height()*2)

	

func enable():
	visible = true
	self.position = get_global_mouse_position()


func disable():
	visible = false
