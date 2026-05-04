## Handles generating the battle, enemies involved and choosing any additional modifiers for generating
## the battle.
class_name BattleScene extends BaseEventScene

#region Declarations
@export_category("Node References")
@export var actions_menu : PanelContainer
@export var battle_log : VBoxContainer
@export var turn_tracker : Control
@export var battle_map : BattleMap
@export var hover_panel : VBoxContainer

# TODO: Need to procedurally determine what enemies are able to fight based off of the current
# difficulty rating.

var enemy_count : int = 0
var reward_tier : int = 1
var elite_modifier : float = 1.0
var special_ability : bool = false
var boss_type : int = 1
#endregion

#region Events
func _ready() -> void:
	CombatManager.start_battle(self)
	
	battle_map.turn_tracker = turn_tracker
	
	_signal_initialization()
	battle_map.init()

## Sets up all the signals within the _ready function
func _signal_initialization() -> void:
	CombatManager.battle_end.connect(_on_map_ended)
	
	battle_map.camera.hover_tile.connect(_on_tile_hovered)
	battle_map.camera.collapse_hover.connect(_collapse_tile_panel)
	
	
	turn_tracker.new_turn.connect(battle_map._on_new_turn)
#endregion

#region Signal Callbacks
func _on_pressed() -> void:
	SceneManager.load_next_scene()

func _on_map_ended() -> void:
	_on_pressed()
	
func _on_tile_hovered() -> void:
	hover_panel.tile_hover()
	
func _collapse_tile_panel() -> void:
	hover_panel.disable()
#endregion
