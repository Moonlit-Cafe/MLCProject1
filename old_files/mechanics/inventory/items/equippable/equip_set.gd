class_name EquipSet extends Resource

var s_name : String
var set_id : int
var desc : String
var effect : String
var required : int

func load_data(cur_set:Dictionary, id) -> void:
	set_id = id as int
	s_name = cur_set.set_name
	effect = cur_set.set_effect
	desc = cur_set.set_desc
	required = cur_set.required as int
