class_name CombatAction extends Action

enum ResourceType {
	NONE,
	HP,
	STAMINA,
	AETHER
}

@export var ac_cost : AbilityCostPacket = AbilityCostPacket.new() ## The cost of the action
@export var damage_type : Genum.DamageType ## The kind of damage this action takes by default
@export var value : float = 1. ## The raw damage this action puts out
@export var a_range : int = 1 ## The distance an action may be carried.
