class_name DataManipulationHelper

func detect_special_data(value: String) -> Variant:
	var rgx := RegEx.new()
	if value.contains("Vec["):
		rgx.compile("(\\d+),(\\d+)")
		var result = rgx.search(value).get_string().split(",")
		return Vector2(result.get(0).to_int(), result.get(1).to_int())
	elif value.contains(";"):
		var ret_arr : Array[int] = []
		for i in value.split(";"):
			if i.is_empty():
				continue
			ret_arr.append(i.to_int())
		print(ret_arr)
		return ret_arr
	elif value.is_valid_int():
		return value.to_int()
	return value

func encode_special_data(value: Variant) -> String:
	if value is Vector2i:
		return "Vec[%s,%s]" % [value.x, value.y]
	elif value is Array[int]:
		var string_arr : String = ""
		for i in value:
			string_arr += "%s;" % i
		if string_arr == "":
			string_arr = ";"
		return string_arr
	elif value is int:
		return "%s" % value
	elif (value is String) or (value is StringName):
		return value
	
	return ""

static func shift_array(arr: Array, shift_amnt: int) -> Array:
	for i in range(shift_amnt):
		var temp_var = arr.pop_back()
		arr.push_front(temp_var)
	
	return arr
