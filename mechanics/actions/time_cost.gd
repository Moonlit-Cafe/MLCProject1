class_name TimeCost extends Resource

#region Declarations
@export var type : Genum.TimeType
@export var value : int
#endregion

#region Statics
static func create(n_type: Genum.TimeType, n_value: int) -> TimeCost:
	var n_cost := TimeCost.new()
	n_cost.type = n_type
	n_cost.value = n_value
	return n_cost
#endregion
