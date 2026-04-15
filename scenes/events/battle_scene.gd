## Handles generating the battle, enemies involved and choosing any additional modifiers for generating
## the battle.
class_name BattleScene extends BaseEventScene

#region Declarations
@export_category("Node References")
@export var hp_label : Label
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
# TODO: Move battle generation to this script later
# The actual battle generation will happen here and then get passed to board
# for right now it's all on the board

#region Events
func _ready() -> void:
	#_determine_battle_view_size() # Grabs the size of the 
	_fill_action_menu()
	_generate_battle()
	
	battle_map.turn_tracker = turn_tracker
	PlayerManager.hp = PlayerManager.combat_stats.get(Genum.StatType.HEALTH)
	hp_label.text = "HP: %s" % PlayerManager.hp
	
	_signal_initialization()
	battle_map.init()
	#CombatManager.selected_action = PlayerManager.available_skills[0]  ## HACK Just testing auto selecting first action as the "first action in the players available skills"

# TODO: Replace with ActionMenu Functionality
func _fill_action_menu() -> void:
	# REMOVE Tyler - implementing this just so Player has an action to test
	var t = ResourceManager.action_compendium
	PlayerManager.available_skills.append(t[&"ACT_0"])
	
	for action in PlayerManager.available_skills:
		actions_menu.add_to_actions(action)
	
	for usable in PlayerManager.get_usables():
		actions_menu.add_to_items(usable)

# TODO: Fix generation later
func _generate_battle() -> void:
	enemy_count = 3
	
	var available_spots : Array[Vector2i]
	for tile in battle_map.board.keys():
		if battle_map.board.get(tile).state == BattleTile.BattleState.EMPTY:
			available_spots.append(tile)
	
	var start_pos = (battle_map.board_zone.size / 2.0) as Vector3i + battle_map.board_zone.pos - Vector3i.ONE
	start_pos = Vector2i(start_pos.x, start_pos.z)
	available_spots.erase(start_pos)
	battle_map.board.get(start_pos).attach_object(PlayerManager.character_data)
	PlayerManager.entity_ref = battle_map.board.get(start_pos).held_entity
	
	for i in range(enemy_count):
		start_pos = available_spots.pick_random()
		available_spots.erase(start_pos)
		print("Attached enemy on tile %s" % start_pos)
		battle_map.board.get(start_pos).attach_object(CombatManager.enemy_compendium.get(0))
	
	var obstacle_count : int = 2
	for i in range(obstacle_count):
		start_pos = available_spots.pick_random()
		available_spots.erase(start_pos)
		battle_map.board.get(start_pos).attach_object(CombatManager.obstacle_compendium.get(0))

## Sets up all the signals within the _ready function
func _signal_initialization() -> void:
	battle_map.end_map.connect(_on_map_ended)
	
	GameGlobalEvents.game_end.connect(_on_game_ended)
	
	CombatManager.hp_changed.connect(_on_hp_changed)
	CombatManager.battle_end.connect(_on_battle_ended)
	CombatManager.attack_tile.connect(action_on_tiles)
	
	battle_map.camera.hover_tile.connect(_on_tile_hovered)
	battle_map.camera.collapse_hover.connect(_collapse_tile_panel)
	
	
	turn_tracker.new_turn.connect(battle_map._on_new_turn)
#endregion

#region Helpers
func action_on_tiles() -> void:
	# TODO: Attach to Battle_board instead of actuating here.
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
		_attack_tile(cur_tile, action)


	MouseHandler.selected_tile = null
	battle_map.determine_selectables()
	CombatManager.player_turn = false
	GameGlobalEvents.player_turn.emit()
	CombatManager.use_action.emit()
		
func _attack_tile(cur_tile:BattleTile, action:CombatAction):
	if not cur_tile:
		return
		
	if not cur_tile.held_entity:
		return 
	
	if CombatManager.selected_action is Usable:
		CombatManager.selected_action.linked_slot.count -= 1
			
	battle_log.log_item(str(CombatManager.selected_action.value) + " damage dealt to " + str(cur_tile.held_entity.character.o_name))
	cur_tile.defend(action, PlayerManager.entity_ref)
#endregion

#region Signal Callbacks
func _on_pressed() -> void:
	SceneManager.load_next_scene()

func _on_map_ended() -> void:
	_on_pressed()


	

## Changes the hp label based on current value.
func _on_hp_changed() -> void:
	hp_label.text = "HP: %s" % PlayerManager.hp

func _on_battle_ended() -> void:
	_on_map_ended()

func _on_game_ended() -> void:
	get_tree().quit()
	
func _on_tile_hovered() -> void:
	hover_panel.tile_hover()
	
func _collapse_tile_panel() -> void:
	hover_panel.disable()
#endregion
