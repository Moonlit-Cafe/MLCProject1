## A resource to act similar to Rect2i, but for the new 3D map system
class_name MapBoundary extends Resource

#region Declarations
var pos := Vector3i.ZERO
var size := Vector3i.ONE
#endregion

#region Events
## Grabs the next point going from left to right, up to down, back to front.
func next_point(point: Vector3i) -> Vector3i:
	var new_pos := point
	if point.x + 1 > (size.x + pos.x):
		new_pos.x = pos.x
		if point.z + 1 > (size.z + pos.z):
			new_pos.z = pos.z
			if point.y + 1 > (size.y + pos.y):
				return pos - Vector3i.ONE
			else:
				new_pos.y += 1
		else:
			new_pos.y += 1
	else:
		new_pos.x += 1
	
	return new_pos

## Takes a given gridmap and scans within this boundary to find all the surface tiles.
func scan_map(map: GridMap) -> Array[Vector3i]:
	var point := pos
	var block_arr : Array[Vector2i]
	var ret_arr : Array[Vector3i]
	while point != (pos - Vector3i.ONE):
		if Vector2i(point.x, point.y) in block_arr:
			point = next_point(point)
			continue
		
		var cell = map.get_cell_item(point)
		if cell:
			block_arr.append(Vector2i(point.x, point.y))
			ret_arr.append(point)
		point = next_point(point)
	
	return ret_arr
#endregion
