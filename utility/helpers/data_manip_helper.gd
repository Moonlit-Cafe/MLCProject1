class_name DataManipulationHelper

func detect_special_data(value: Variant) -> Variant:
	if value is not String:
		return value
	
	var rgx := RegEx.new()
	# Detect Vectors
	if value.contains("Vec["):
		rgx.compile("(-?\\d+),\\s*(-?\\d+)")
		var result = rgx.search(value).get_string().split(",")
		return Vector2(result.get(0).to_int(), result.get(1).to_int())
	#Detect Vector Arrays
	elif value.contains("VecArr["):
		rgx.compile("\\((-?\\d*),\\s*(-?\\d*)\\)")
		var result = rgx.search_all(value)
		var ret_result : Array[Vector2i] = []
		for res in result:
			var split_result = res.get_string().split(",")
			ret_result.append(Vector2i(split_result.get(0).to_int(), split_result.get(1).to_int()))
		return ret_result
	#Detect Int Arrays
	elif value.contains(";"):
		var ret_arr : Array[int] = []
		for i in value.split(";"):
			if i.is_empty():
				continue
			ret_arr.append(i.to_int())
		return ret_arr
	#Detects Ability Packet Data
	elif value.contains("AbilityCost["):
		rgx.compile("(\\d+),\\s*(-?\\d+)")
		var result = rgx.search(value).get_string().split(",")
		print(result)
		var new_cost := AbilityCostPacket.new()
		new_cost.cost_type = result.get(0).to_int() as AbilityCostPacket.CostType
		new_cost.cost_amount = result.get(1).to_int()
		return new_cost
	elif value.is_valid_int():
		return value.to_int()
	elif value.is_valid_float():
		return value.to_float()
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
		
	elif value is Array[Vector2i]:
		# TODO: Make this more compact later, for now simple is fine.
		var string_arr : String = "VecArr["
		var idx : int = 0
		for tile in value:
			string_arr += "(%s, %s)" % [tile.x, tile.y]
			if idx < value.size():
				string_arr += ","
			idx += 1
		string_arr += "]"
		return string_arr
		
	elif value is AbilityCostPacket:
		return "AbilityCost[%s,%s]" % [value.cost_type, value.cost_amount]
		
	elif value is ActionShape:
		return value.shape_id
		
	elif value is int or value is float:
		return "%s" % value
		
	elif (value is String) or (value is StringName):
		return value
	
	return ""

static func shift_array(arr: Array, shift_amnt: int) -> Array:
	for i in range(shift_amnt):
		var temp_var = arr.pop_back()
		arr.push_front(temp_var)
	
	return arr
