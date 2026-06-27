## Holds all the necessary data for generating a zone for combat.
class_name ZoneData extends Resource

#region Declarations
@export var tiles_used : Array[StringName] = []
@export var height_range : Curve
@export var map_size : Vector2i = Vector2i(11, 11)
#endregion
