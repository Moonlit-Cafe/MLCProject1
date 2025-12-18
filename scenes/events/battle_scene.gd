## Handles generating the battle, enemies involved and choosing any additional modifiers for generating
## the battle.
extends BaseEventScene

#region Declarations
@export var battle_viewport : SubViewportContainer
@export var label : Label
@export var hp_label : Label

@onready var hp_container : VBoxContainer = $HPContainer/VBoxContainer
@onready var actions_menu : PanelContainer = $ActionMenu
@onready var battle_log : VBoxContainer = $InfoPanel/VBoxContainer/BattleLog
@onready var turn_tracker : Control = $TurnTracker
@onready var battle_board : Node2D = $SubViewportContainer/SubViewport/BattleMap
@onready var enemy_info : VBoxContainer = $InfoPanel/VBoxContainer/EnemyInfo
@onready var enemy_label : Label = $InfoPanel/VBoxContainer/EnemyInfo/EnemyName
@onready var enemy_hp_bar : ProgressBar = $InfoPanel/VBoxContainer/EnemyInfo/HealthBar

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
	_determine_battle_view_size() # Grabs the size of the 
	_fill_action_menu()
	enemy_count = 3
	_generate_battle()
	
	battle_board.turn_tracker = turn_tracker
	PlayerManager.hp = PlayerManager.combat_stats.get(Genum.StatType.HEALTH)
	hp_label.text = "HP: %s" % PlayerManager.hp
	
	_signal_initialization()
	battle_board.init()
	CombatManager.selected_action = PlayerManager.available_skills[0]  ## Just testing auto selecting first action as the "first action in the players available skills"
	hp_container.update_ticks(Vector3i(1, 0, 0))

## Grab the size of the battle map and viewport for resizing within the scene.
func _determine_battle_view_size() -> void:
	if not battle_viewport:
		push_warning("There is no viewport to change...")
		return
	
	# TODO: This is currently hard-coded, need to extrapolate later...
	var board_size = battle_board.board_area.size
	var map_min = mini(board_size.x, board_size.y)
	var map_max = maxi(board_size.x, board_size.y)
	var l = map_max * battle_board.board_tile_size.x
	var l_delta = l
	var m = 1.
	var h_len = get_window().size.x * .4
	while l < h_len:
		m += 1
		l = l_delta * m
	
	# TODO: Optimize this later, it's clunky and assumes y-len > x-len
	var h_size = l / get_window().size.x
	var v_size = l / get_window().size.y
	battle_viewport.anchor_top = (1 - v_size) / 2.
	battle_viewport.anchor_bottom = 1 - ((1 - v_size) / 2.)
	battle_viewport.anchor_left = (1 - h_size) / 2.
	battle_viewport.anchor_right = 1 - ((1 - h_size) / 2.)
	battle_viewport.stretch = true
	battle_viewport.stretch_shrink = int(m)
	@warning_ignore("integer_division")
	battle_board.position += Vector2((map_max - map_min) / 2, 0) * battle_board.board_tile_size.x

# TODO: Replace with ActionMenu Functionality
func _fill_action_menu() -> void:
	for action in PlayerManager.available_skills:
		actions_menu.add_to_actions(action)
	
	for usable in PlayerManager.get_usables():
		actions_menu.add_to_items(usable)

# TODO: Fix generation later
func _generate_battle() -> void:
	var board_size = battle_board.board_area.size
	var available_spots : Array[Vector2i]
	for x in range(board_size.x):
		for y in range(board_size.y):
			available_spots.append(Vector2i(x, y))
	
	for i in range(enemy_count):
		var pos = available_spots.pick_random()
		available_spots.erase(pos)
		battle_board.board.get(pos.x).get(pos.y).attach_object(CombatManager.enemy_compendium.get(0))
	
	var obstacle_count : int = 2
	for i in range(obstacle_count):
		var pos = available_spots.pick_random()
		available_spots.erase(pos)
		battle_board.board.get(pos.x).get(pos.y).attach_object(CombatManager.obstacle_compendium.get(0))

## Sets up all the signals within the _ready function
func _signal_initialization() -> void:
	battle_board.end_map.connect(_on_map_ended)
	
	GameGlobalEvents.hp_changed.connect(_on_hp_changed)
	GameGlobalEvents.battle_end.connect(_on_battle_ended)
	GameGlobalEvents.game_end.connect(_on_game_ended)
	GameGlobalEvents.attack_tile.connect(_attack_tile)
#endregion

#region Processes
func _process(_delta: float) -> void:
	_update_hp_label()

# FIXME: Bug with the health-bars, related to still having Selected Tile in mouse handler probably.
func _update_hp_label() -> void:
	if not MouseHandler.selected_tile:
		if enemy_info.visible:
			enemy_info.hide()
		return
	
	if MouseHandler.selected_tile.state == BattleTile.BattleState.EMPTY:
		return
	
	if not enemy_info.visible:
		enemy_info.show()
	enemy_label.text = MouseHandler.selected_tile.name
	enemy_hp_bar.max_value = MouseHandler.selected_tile.held_entity.max_hp
	enemy_hp_bar.step = float(MouseHandler.selected_tile.held_entity.max_hp) / 10000
	enemy_hp_bar.value = MouseHandler.selected_tile.held_entity.hp
#endregion

#region Signal Callbacks
func _on_pressed() -> void:
	SceneManager.load_next_scene()

func _on_map_ended() -> void:
	_on_pressed()

func _attack_tile() -> void:
	# TODO: Attach to Battle_board instead of actuating here.
	battle_log.log_item("This is log test...")
	if not CombatManager.selected_action or not CombatManager.player_turn:
		return

	MouseHandler.selected_tile.defend(CombatManager.selected_action)
	MouseHandler.selected_tile = null
	battle_board.determine_selectables()
	get_tree().call_group(&"tiles", "refresh_highlight")
	CombatManager.player_turn = false
	GameGlobalEvents.player_turn.emit()

## Changes the hp label based on current value.
func _on_hp_changed() -> void:
	hp_label.text = "HP: %s" % PlayerManager.hp

func _on_battle_ended() -> void:
	_on_map_ended()

func _on_game_ended() -> void:
	get_tree().quit()
#endregion
