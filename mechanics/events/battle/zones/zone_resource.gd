## Holds the data for a specific zone to use with ZoneManager
class_name ZoneResource extends Resource

#region Declarations
@export var zone_id : StringName = &"" ## The raw ID for the zone
@export var zone_title : StringName = &"" ## The in-game name for the zone
@export var tile_set : MeshLibrary ## The Meshlibrary for said zone
#endregion
