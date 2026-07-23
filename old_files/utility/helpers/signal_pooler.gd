class_name SignalPooler

#region Declaration
var signal_groups : Dictionary[StringName, Array]
#endregion

#region Events
func add_to_group(group_name: StringName, node_to_add: Node) -> void:
	if not signal_groups.has(group_name):
		signal_groups.set(group_name, [])
	
	signal_groups.get(group_name).append(node_to_add)

func pool_value(caller: Node, group_name: StringName, value: String) -> Array:
	if not signal_groups.has(group_name):
		push_warning("There is no group by the name of ", group_name)
		return []
	
	var ret_arr : Array = []
	for node in signal_groups.get(group_name):
		if node == caller:
			continue
		ret_arr.append(node.get(value))
	
	return ret_arr
#endregion
