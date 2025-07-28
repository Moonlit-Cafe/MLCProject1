## The Item resource type for declaration with every single item in the game.
class_name Item extends Resource

@export var i_name : StringName
@export var id : int
@export var value : int
@export var tags : Array[Genum.ItemTags]
@export var texture : Vector2i
@export var tooltip : String
@export var tier : int
@export var max_stack : int = 1
