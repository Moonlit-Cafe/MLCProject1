class_name ObstacleObject extends Resource

@export var o_name : StringName
@export var frames : SpriteFrames
@export var stats : Dictionary[StringName, int] = {
	&"hp": 10,
	&"defense": 0,
}

func defend(ac: Action) -> int:
	var attack_value := int(ac.value)
	# TODO: Differentiate between magic attacks and physical attacks.
	return attack_value - stats.get(&"defense")
