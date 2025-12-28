## Node specific to generating zones for BattleMaps
class_name ZoneManager extends Node

#region Declarations
var current_zone : ZoneResource
#endregion

#region Events
func _ready() -> void:
	print("Initialized: ZoneManager")

func generate_map(map: GridMap, boundary: MapBoundary) -> void:
	if not current_zone:
		return
	
	if current_zone.tile_set.get_item_list().size() < 1:
		return
	
	for x in range(boundary.size.x):
		for z in range(boundary.size.z):
			map.set_cell_item(Vector3i(x, 0, z), 0)
	
	print(map.get_used_cells())
#endregion
