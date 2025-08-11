# ProgScene.gd - Main scene progression controller
class_name ProgScene
extends Node

@export var game_seed: int = 0
var rng: RandomNumberGenerator
var current_scene_index: int = 0
var event_history: Array[String] = []

# Scene weights for generation probability (for non-fixed floors)
var scene_weights = {
	"BattleScene": 60,
	"UniqueEventScene": 30,
	"ShopScene": 10,
	"CraftScene": 0,  # Not used in random generation, handled by floor pattern
	"BossScene": 0   # Not used in random generation, handled by floor pattern
}

signal scene_changed(scene_type: String, scene_data: Dictionary)

func _ready():
	if game_seed == 0:
		game_seed = randi()
	
	rng = RandomNumberGenerator.new()
	rng.seed = game_seed
	print("Game initialized with seed: ", game_seed)

func generate_next_event() -> Dictionary:
	current_scene_index += 1
	
	var scene_type = _get_scene_type()
	var scene_data = _generate_scene_data(scene_type)
	
	event_history.append(scene_type)
	
	print("Generated event #", current_scene_index, ": ", scene_type)
	scene_changed.emit(scene_type, scene_data)
	
	return scene_data

func _get_scene_type() -> String:
	# Check if this is a boss floor (every 10th floor: 10, 20, 30, etc.)
	if current_scene_index % 10 == 0:
		return "BossScene"
	
	# Check if this is a crafting floor (n%10 + 1 pattern: 11, 21, 31, etc.)
	if current_scene_index % 10 == 1 and current_scene_index > 1:
		return "CraftScene"
	
	# Otherwise use weighted random generation (excluding BossScene and CraftScene)
	return _get_weighted_random_scene()

func _get_weighted_random_scene() -> String:
	# Create weights excluding BossScene and CraftScene since they're handled by floor patterns
	var filtered_weights = scene_weights.duplicate()
	filtered_weights.erase("CraftScene")
	filtered_weights.erase("BossScene")
	
	var total_weight = 0
	for weight in filtered_weights.values():
		total_weight += weight
	
	var random_value = rng.randi_range(1, total_weight)
	var current_weight = 0
	
	for scene_type in filtered_weights.keys():
		current_weight += filtered_weights[scene_type]
		if random_value <= current_weight:
			# If we selected BattleScene, check for Elite variant (20% chance)
			if scene_type == "BattleScene" and rng.randi_range(1, 100) <= 20:
				return "EliteBattleScene"
			return scene_type
	
	return "BattleScene" # fallback

func _generate_scene_data(scene_type: String) -> Dictionary:
	var base_data = {
		"scene_type": scene_type,
		"scene_index": current_scene_index,
		"seed_value": rng.randi()
	}
	
	match scene_type:
		"CraftScene":
			return _generate_craft_data(base_data)
		"BattleScene":
			return _generate_battle_data(base_data)
		"EliteBattleScene":
			return _generate_elite_battle_data(base_data)
		"BossScene":
			return _generate_boss_data(base_data)
		"ShopScene":
			return _generate_shop_data(base_data)
		"UniqueEventScene":
			return _generate_unique_event_data(base_data)
		_:
			return base_data

func _generate_craft_data(base_data: Dictionary) -> Dictionary:
	base_data["craft_type"] = ["weapon", "armor", "consumable"][rng.randi() % 3]
	base_data["materials_required"] = rng.randi_range(1, 3)
	return base_data

func _generate_battle_data(base_data: Dictionary) -> Dictionary:
	base_data["enemy_count"] = rng.randi_range(1, 4)
	base_data["difficulty"] = rng.randi_range(1, 5)
	base_data["reward_tier"] = rng.randi_range(1, 3)
	return base_data

func _generate_elite_battle_data(base_data: Dictionary) -> Dictionary:
	base_data["enemy_count"] = rng.randi_range(2, 5)  # More enemies than regular battle
	base_data["difficulty"] = rng.randi_range(3, 7)   # Higher difficulty range
	base_data["reward_tier"] = rng.randi_range(2, 4)  # Better rewards
	base_data["elite_modifier"] = rng.randf_range(1.3, 1.8)  # Damage/health multiplier
	base_data["special_ability"] = true
	return base_data

func _generate_boss_data(base_data: Dictionary) -> Dictionary:
	base_data["boss_tier"] = (current_scene_index / 10)  # Boss gets stronger each 10 floors
	base_data["boss_type"] = ["elemental", "mechanical", "undead", "dragon"][rng.randi() % 4]
	base_data["special_abilities"] = rng.randi_range(2, 5)
	base_data["reward_multiplier"] = 2.0 + (base_data["boss_tier"] * 0.5)
	return base_data

func _generate_shop_data(base_data: Dictionary) -> Dictionary:
	base_data["shop_type"] = ["general", "weapons", "magic"][rng.randi() % 3]
	base_data["item_count"] = rng.randi_range(3, 8)
	base_data["price_modifier"] = rng.randf_range(0.8, 1.2)
	return base_data

func _generate_unique_event_data(base_data: Dictionary) -> Dictionary:
	base_data["event_id"] = rng.randi_range(1, 100)
	base_data["choices_available"] = rng.randi_range(2, 4)
	base_data["risk_level"] = rng.randi_range(1, 3)
	return base_data

func get_scene_history() -> Array[String]:
	return event_history.duplicate()

func reset_progression():
	current_scene_index = 0
	event_history.clear()
	rng.seed = game_seed

# Utility function to get deterministic value based on scene index
func get_deterministic_value(min_val: int, max_val: int, offset: int = 0) -> int:
	var temp_rng = RandomNumberGenerator.new()
	temp_rng.seed = game_seed + current_scene_index + offset
	return temp_rng.randi_range(min_val, max_val)
