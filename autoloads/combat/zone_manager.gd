## Node specific to generating zones for BattleMaps
class_name ZoneManager extends Node

#region Declarations
var current_zone : ZoneResource
var meshes : Dictionary[Vector3, Variant]
var surface_meshes : Dictionary[Vector2i, Variant]
#endregion

#region Events
func _ready() -> void:
	print("Initialized: ZoneManager")

func generate_map(map: GridMap, boundary: MapBoundary) -> void:
	# TODO: Make more complex based on ZoneResource data.
	if not current_zone:
		return
	
	if current_zone.tile_set.get_item_list().size() < 1:
		return
	
	for x in range(boundary.size.x):
		for z in range(boundary.size.z):
			map.set_cell_item(Vector3i(x, 0, z), 0)
	
	_get_meshes(map)
	_get_surface_meshes()
	print(surface_meshes)

func _get_meshes(map: GridMap) -> void:
	var mesh_list := map.get_meshes()
	var i := 0
	var temp_transform : Transform3D
	for mesh in mesh_list:
		if i % 2 == 0:
			temp_transform = mesh
		else:
			meshes.set(temp_transform.origin, mesh)
		
		i += 1

func _get_surface_meshes() -> void:
	for vec in meshes.keys():
		var vec_i := Vector2i(vec.x, vec.z)
		if vec_i in surface_meshes:
			var compare_vec = meshes.find_key(surface_meshes.get(vec_i))
			if compare_vec.y > vec.y:
				continue
		
		surface_meshes.set(vec_i, meshes.get(vec))
#endregion
