class_name Decider extends Resource

#region exports
@export var response : Curve
#endregion

#region from Abstract Parent

func score(p_stat:Dictionary) -> float :
	

	print("My HP: %s, Player HP: %s" % [p_stat["enemy"][0],p_stat["player"][0]])
	print("My HP Response: %s" % response.sample(p_stat["enemy"][0]))
	return response.sample(.5)

#endregion

	
	
