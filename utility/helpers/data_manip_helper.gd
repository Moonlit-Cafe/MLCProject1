class_name DataManipulationHelper

static func shift_array(arr: Array, shift_amnt: int) -> Array:
	for i in range(shift_amnt):
		var temp_var = arr.pop_back()
		arr.push_front(temp_var)
	
	return arr
