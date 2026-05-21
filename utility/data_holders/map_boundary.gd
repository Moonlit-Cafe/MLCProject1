## A resource to act similar to Rect2i, but for the new 3D map system
class_name MapBoundary extends Resource

#region Declarations
signal scan_complete()

@export var pos := Vector3i.ZERO
@export var size := Vector3i.ONE
#endregion

#region Events
## Takes a given gridmap and scans within this boundary to find all the surface tiles.
func scan_map(map: GridMap) -> Array[Vector3i]:
	var used_cells := map.get_used_cells()
	var remaining := used_cells.duplicate()
	var ret_arr : Array[Vector3i] = []
	for cell in used_cells:
		if not remaining.has(cell):
			continue
		remaining.erase(cell)
		var top := cell
		for other_cell in used_cells:
			if not remaining.has(other_cell):
				continue
			
			if other_cell.x != cell.x or other_cell.z != cell.z:
				continue
			
			remaining.erase(other_cell)
			if top.y < other_cell.y:
				top = other_cell
		
		ret_arr.append(top)
	
	scan_complete.emit()
	return ret_arr
#endregion
