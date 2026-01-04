## Autoload in charge of data regarding battles and combat.
extends Node

#region Declarations
@warning_ignore("unused_signal")
signal tile_in_arr(tile: BattleTile)

@export var enemy_compendium : Array[EnemyCharacter] = [] ## The entire list of available enemies
@export var obstacle_compendium : Array[ObstacleObject] = [] ## The entire list of available obstacles
@export_category(&"Manager Scenes")
@export var skill_manager_scene : PackedScene ## A reference to the SkillManager Scene for instantiation
@export var zone_manager_scene : PackedScene ## A reference to the ZoneManager for instatiation

## A reference of the current Battle Map
var battle_map : BattleMap :
	set(value):
		battle_map = value
		if not value:
			return
		
		battle_map.end_map.connect(clean_up)

var game_difficulty : float = 1 ## The chosen or set difficulty of the game
var difficulty_modifier : float = 1 ## The growing difficulty as the game goes on
var level_number : float = 1 ## The position on the difficulty curve, not yet defined
var selected_action : Action ## The currently selected action
var player_turn : bool = true ## Is it currently the player's turn?
var skill_manager : SkillManager ## The skill manager node
var zone_manager : ZoneManager ## The zone manager node
var moving : bool = false
#endregion

#region Events
func _ready() -> void:
	_instantiate_managers()

## Updates the game's difficulty, if [param can_increase] is true, then will auto increment [br]
## the level_number.
func update_difficulty(can_increase: bool = false) -> void:
	# PLANNED: Come back to this for tweaking when demo-ing the game.
	if can_increase:
		level_number += 1
	difficulty_modifier = game_difficulty * pow(5, (level_number - 1) / 10)

## Used to clean up the CombatManager of unnecessary references and values.
func clean_up() -> void:
	battle_map = null
	selected_action = null

func _instantiate_managers() -> void:
	if not skill_manager_scene and zone_manager_scene:
		return
	
	print("Initializing: Combat sub-managers")
	skill_manager = skill_manager_scene.instantiate()
	zone_manager = zone_manager_scene.instantiate()
	
	add_child(skill_manager)
	add_child(zone_manager)
	print("Initialized: CombatManager")
#endregion
