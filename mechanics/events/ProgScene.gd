## Progression Scene, wher the actual "game" is held. Controls the progression
## of events such as the Shop, Battle, etc.
class_name ProgScene extends CanvasLayer

#region Declarations
signal scene_changed(scene_type: String, scene_data: Dictionary)

@export var event_references : Array[EventHolder]
@export var button_container : VBoxContainer

var current_scene_index: int = 0
var event_history: Array[String] = []
var frequency_events : Array[EventHolder]
var random_events : Array[EventHolder]
var is_frequency := false
var generation_height : int = 3
#endregion

#region Built-Ins
func _ready() -> void:
	SceneManager.prog_scene = self
	_setup_progression()
#endregion

#region Scene Generation
func generate_next_events() -> void:
	current_scene_index += 1
	var event_set : Array[EventHolder] = _generate_events()
	for event_button in button_container:
		button_container.remove_child(event_button)
	
	if event_set.size() > 1:
		for i in range(generation_height):
			_generate_event_button(event_set)
	else:
		_generate_event_button(event_set)

func _generate_events() -> Array[EventHolder]:
	var valid_events : Array[EventHolder] = []
	for event in frequency_events:
		if current_scene_index % event.spawn_frequency == 0:
			valid_events.append(event)
	
	if valid_events.size() > 1:
		var priority_event : EventHolder = null
		for event in valid_events:
			if not priority_event:
				priority_event = event
				continue
			
			if priority_event.priority < event.priority:
				valid_events.erase(priority_event)
				priority_event = event
	elif valid_events.size() == 0:
		return random_events
	
	return valid_events
#endregion

#region Helpers
func _setup_progression() -> void:
	for event in event_references:
		if event.spawn_frequency != -1:
			frequency_events.append(event)
		else:
			random_events.append(event)

func _generate_event_button(event_set: Array[EventHolder]) -> void:
	var event_button := EventButton.new()
	var chosen_event = _choose_event(event_set)
	event_button.event = chosen_event
	event_button.text = chosen_event.scene_name
	button_container.add_child(event_button)
#endregion

#region Publics
func get_event_history() -> Array[String]:
	return event_history.duplicate()

func reset_progression():
	current_scene_index = 0
	event_history.clear()
	GameGlobal.rng.state = 0

# Utility function to get deterministic value based on scene index
func get_deterministic_value(min_val: int, max_val: int, offset: int = 0) -> int:
	var temp_rng = RandomNumberGenerator.new()
	temp_rng.seed = GameGlobal.rng.seed
	temp_rng.state = GameGlobal.rng.state + current_scene_index + offset
	return temp_rng.randi_range(min_val, max_val)
#endregion

#region Privates
func _choose_event(event_list: Array[EventHolder]) -> EventHolder:
	# Create weights excluding BossScene and CraftScene since they're handled by floor patterns
	var weights : Array[float] = []
	for event in event_list:
		weights.append(float(event.weight))
	
	return event_list.get(GameGlobal.rng.rand_weighted(weights))

#func _generate_scene_data(scene_type: String) -> Dictionary:
#	var base_data = {
#		"scene_type": scene_type,
#		"scene_index": current_scene_index,
#		"seed_value": GameGlobal.rng.randi()
#	}
#	
#	match scene_type:
#		"CraftScene":
#			return _generate_craft_data(base_data)
#		"BattleScene":
#			return _generate_battle_data(base_data)
#		"EliteBattleScene":
#			return _generate_elite_battle_data(base_data)
#		"BossScene":
#			return _generate_boss_data(base_data)
#		"ShopScene":
#			return _generate_shop_data(base_data)
#		"UniqueEventScene":
#			return _generate_unique_event_data(base_data)
#		_:
#			return base_data
#
#func _generate_craft_data(base_data: Dictionary) -> Dictionary:
#	base_data["craft_type"] = ["weapon", "armor", "consumable"][GameGlobal.rng.randi() % 3]
#	base_data["materials_required"] = GameGlobal.rng.randi_range(1, 3)
#	return base_data
#
#func _generate_battle_data(base_data: Dictionary) -> Dictionary:
#	base_data["enemy_count"] = GameGlobal.rng.randi_range(1, 4)
#	base_data["difficulty"] = GameGlobal.rng.randi_range(1, 5)
#	base_data["reward_tier"] = GameGlobal.rng.randi_range(1, 3)
#	return base_data
#
#func _generate_elite_battle_data(base_data: Dictionary) -> Dictionary:
#	base_data["enemy_count"] = GameGlobal.rng.randi_range(2, 5)  # More enemies than regular battle
#	base_data["difficulty"] = GameGlobal.rng.randi_range(3, 7)   # Higher difficulty range
#	base_data["reward_tier"] = GameGlobal.rng.randi_range(2, 4)  # Better rewards
#	base_data["elite_modifier"] = GameGlobal.rng.randf_range(1.3, 1.8)  # Damage/health multiplier
#	base_data["special_ability"] = true
#	return base_data
#
#func _generate_boss_data(base_data: Dictionary) -> Dictionary:
#	base_data["boss_tier"] = (current_scene_index / 10)  # Boss gets stronger each 10 floors
#	base_data["boss_type"] = ["elemental", "mechanical", "undead", "dragon"][GameGlobal.rng.randi() % 4]
#	base_data["special_abilities"] = GameGlobal.rng.randi_range(2, 5)
#	base_data["reward_multiplier"] = 2.0 + (base_data["boss_tier"] * 0.5)
#	return base_data
#
#func _generate_shop_data(base_data: Dictionary) -> Dictionary:
#	base_data["shop_type"] = ["general", "weapons", "magic"][GameGlobal.rng.randi() % 3]
#	base_data["item_count"] = GameGlobal.rng.randi_range(3, 8)
#	base_data["price_modifier"] = GameGlobal.rng.randf_range(0.8, 1.2)
#	return base_data
#
#func _generate_unique_event_data(base_data: Dictionary) -> Dictionary:
#	base_data["event_id"] = GameGlobal.rng.randi_range(1, 100)
#	base_data["choices_available"] = GameGlobal.rng.randi_range(2, 4)
#	base_data["risk_level"] = GameGlobal.rng.randi_range(1, 3)
#	return base_data
#endregion
