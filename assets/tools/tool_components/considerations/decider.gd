class_name Decider extends Resource

#region exports
@export var name: String
@export var response : Curve
#endregion

#region from Abstract Parent

func score(unit:UnitBox, origin_unit:UnitBox) -> float :
	match name:
		"my_hp" :
			return response.sample_baked(origin_unit.health/100)
		"target_hp" :
			return response.sample_baked(unit.health/100)
		"my_resource" :
			return response.sample_baked(origin_unit.mana/100)
		_:
			return -1

#endregion

	
	
