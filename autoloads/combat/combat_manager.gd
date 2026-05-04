## Autoload in charge of data regarding battles and combat.
extends Node

#region Declarations
@warning_ignore_start("unused_signal")
signal attack_tile
signal battle_end
signal hp_changed
signal use_action
signal rehover
signal tile_in_arr(tile: BattleTile)
@warning_ignore_restore("unused_signal")

@export var combat_machine_scene : PackedScene
var combat_machine : StateMachine
@export var enemy_compendium : Array[EnemyCharacter] = [] ## The entire list of available enemies
@export var obstacle_compendium : Array[ObstacleObject] = [] ## The entire list of available obstacles
@export_category(&"Manager Scenes")
@export var zone_manager_scene : PackedScene ## A reference to the ZoneManager for instatiation
@export var item_manager_scene : PackedScene ## A reference to the ItemManager for instatiation

## A reference of the current Battle Map
var battle_map : BattleMap :
	set(value):
		battle_map = value
		if not value:
			return
		
		battle_end.connect(clean_up)
var battle_log : VBoxContainer

var difficulty_modifier : float = 1 ## The growing difficulty as the game goes on
var game_difficulty : float = 1 ## The chosen or set difficulty of the game
var level_number : float = 1 ## The position on the difficulty curve, not yet defined

var item_manager : ItemManager ## The item manager node
var zone_manager : ZoneManager
var moving : bool = false ## A boolean determining if the Player is currently allowed to move
var player : TilePlayer ## A reference to the actual TileEntity version of the Player
var player_turn : bool = true ## Boolean trackig if it is currently the Player's turn
var selected_action : Action ## The currently selected action within Combat
var tile_signal_pool : SignalPooler ## Handles the information gathering in regards to tiles
#endregion

#region Events
func _ready() -> void:
	_instantiate_managers()
	tile_signal_pool = SignalPooler.new()

## Starts up all the managers via instantiation and adding as children while passing their [br]
## reference to the equivalently named [b]managers[/b]
func _instantiate_managers() -> void:
	print("Initializing: Combat sub-managers")
	zone_manager = zone_manager_scene.instantiate()
	item_manager = item_manager_scene.instantiate()
	
	add_child(zone_manager)
	add_child(item_manager)
	print("Initialized: CombatManager")

## Updates the game's difficulty, if [param can_increase] is true, then will auto increment [br]
## the level_number.
func update_difficulty(can_increase: bool = false) -> void:
	# PLANNED: Come back to this for tweaking when demo-ing the game.
	if can_increase:
		level_number += 1
	difficulty_modifier = game_difficulty * pow(5, (level_number - 1) / 10)

func start_battle(scene: BattleScene) -> void:
	combat_machine = combat_machine_scene.instantiate()
	combat_machine.battle_scene = scene
	add_child(combat_machine)

## Used to clean up the CombatManager of unnecessary references and values.
func clean_up() -> void:
	battle_map = null
	selected_action = null
	battle_log = null

func log_item(log_string: String) -> void:
	battle_log.log(log_string)
#endregion
