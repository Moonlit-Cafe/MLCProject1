## Handles generating the battle, enemies involved and choosing any additional modifiers for generating
## the battle.
class_name BattleView extends SubViewport

#region Declarations
@export_category("Node References")
@export var actions_menu : PanelContainer
@export var battle_log : VBoxContainer
@export var turn_tracker : Control
@export var battle_map : BattleMap
@export var hover_panel : VBoxContainer
@export var viewport_layer : CanvasLayer

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
	_signal_initialization()

## Sets up all the signals within the _ready function
func _signal_initialization() -> void:
	CombatManager.battle_end.connect(_on_map_ended)
	CombatManager.attack_tile.connect(action_on_tiles)
	
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
	
func action_on_tiles() -> void:
	var tile : BattleTile = MouseHandler.selected_tile
	var action = CombatManager.selected_action
	battle_log.log_item("This is log test...")
	
	if not CombatManager.selected_action or not CombatManager.player_turn:
		return
		
	var tile_pos := tile.tile_position
	var center_pos := Vector2i(tile_pos.x, tile_pos.z)
	var tiles := battle_map.grab_other_tiles(action.shape.shape_pos_arr.duplicate(), center_pos)
	tiles.append(tile)
	
	for cur_tile in tiles:
		battle_map.attack_tile(cur_tile, action)


	MouseHandler.selected_tile = null
	battle_map.determine_selectables()
	CombatManager.player_turn = false
	GameGlobal.events.player_turn.emit()
	CombatManager.use_action.emit()
#endregion
