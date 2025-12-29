## A resource to act similar to Rect2i, but for the new 3D map system
class_name MapBoundary extends Resource

#region Declarations
@export var pos := Vector3i.ZERO
@export var size := Vector3i.ONE
#endregion

#region Events
## Grabs the next point going from left to right, up to down, back to front.
func next_point(point: Vector3i) -> Vector3i:
	var o_pos := pos
	var f_pos := pos + size
	point.x += 1
	if point.x < f_pos.x:
		return point
	point.x = o_pos.x
	
	point.z += 1
	if point.z < f_pos.z:
		return point
	point.z = o_pos.z
	
	point.y += 1
	if point.y < f_pos.y:
		return point
	
	return o_pos - Vector3i.ONE

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
		if cell != map.INVALID_CELL_ITEM:
			block_arr.append(Vector2i(point.x, point.y))
			ret_arr.append(point)
		point = next_point(point)
	
	return ret_arr
#endregion
