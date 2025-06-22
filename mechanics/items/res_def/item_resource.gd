## The Item resource type for declaration with every single item in the game.
class_name Item extends Resource

@export var item_name : StringName
@export var item_id : int
@export var item_value : int
@export var item_tags : Array[Genum.ItemTags]
@export var item_texture : Texture2D
@export var item_tooltip : String
