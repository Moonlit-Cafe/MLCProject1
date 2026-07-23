class_name AbilityCostPacket extends Resource

enum CostType {
	STAMINA,
	MANA
}

@export var cost_type := CostType.STAMINA
@export var cost_amount : int = 0
