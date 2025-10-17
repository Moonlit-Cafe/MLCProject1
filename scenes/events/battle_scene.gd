# The main scene for all battle handling.
extends BaseEventScene

#region Declarations
@export var battle_viewport : SubViewportContainer
@export var label : Label
@export var hp_label : Label

@onready var actions_menu : PanelContainer = $ActionMenu

var enemy_count : int = 0
var difficulty : float = 1.0
var reward_tier : int = 1
var elite_modifier : float = 1.0
var special_ability : bool = true
var boss_tier : int = 1
var boss_type : int = 1
var reward_multiplier : float = 1.0
#var selected_action : Action = null :
#	set(value):
#		selected_action = value
#		if label:
#			label.text = "Selected: %s" % (value.ac_name if value else "")
var player_turn : bool = false
#endregion
# TODO: Move battle generation to this script later
# The actual battle generation will happen here and then get passed to board
# for right now it's all on the board

#region Built-Ins
func _ready() -> void:
	CombatManager.current_scene = self
	
	_determine_battle_view_size()
	_fill_actions()
	enemy_count = 3
	_generate_battle()
	CombatManager.current_board.init()
	
	PlayerManager.hp = PlayerManager.combat_stats.get(Genum.StatType.HEALTH)
	hp_label.text = "HP: %s" % PlayerManager.hp
	
	if CombatManager.current_board:
		CombatManager.current_board.end_map.connect(_on_map_ended)
	
	GameGlobalEvents.hp_changed.connect(_on_hp_changed)
	GameGlobalEvents.battle_end.connect(_on_battle_ended)
	GameGlobalEvents.game_end.connect(_on_game_ended)
#endregion

#region Setups
func _determine_battle_view_size() -> void:
	if not battle_viewport:
		push_warning("There is no viewport to change...")
		return
	
	# TODO: This is currently hard-coded, need to extrapolate later...
	var board_size = CombatManager.current_board.board_area.size
	var map_min = mini(board_size.x, board_size.y)
	var map_max = maxi(board_size.x, board_size.y)
	var l = map_max * CombatManager.current_board.board_tile_size.x
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
	CombatManager.current_board.position += Vector2((map_max - map_min) / 2, 0) * CombatManager.current_board.board_tile_size.x
	print(CombatManager.current_board.position)

# TODO: Replace with ActionMenu Functionality
func _fill_actions() -> void:
	for action in PlayerManager.available_skills:
		actions_menu.add_to_actions(action)

# TODO: Fix generation later
func _generate_battle() -> void:
	var board_size = CombatManager.current_board.board_area.size
	var available_spots : Array[Vector2i]
	for x in range(board_size.x):
		for y in range(board_size.y):
			available_spots.append(Vector2i(x, y))
	
	for i in range(enemy_count):
		var pos = available_spots.pick_random()
		available_spots.erase(pos)
		CombatManager.current_board.board.get(pos.x).get(pos.y).attach_object(CombatManager.enemy_compendium.get(0))
	
	var obstacle_count : int = 2
	for i in range(obstacle_count):
		var pos = available_spots.pick_random()
		available_spots.erase(pos)
		CombatManager.current_board.board.get(pos.x).get(pos.y).attach_object(CombatManager.obstacle_compendium.get(0))
#endregion

#region Signal Callbacks
func _on_pressed() -> void:
	SceneManager.load_next_scene()

func _on_map_ended() -> void:
	_on_pressed()

func _on_attack_pressed() -> void:
	print(player_turn)
	if not CombatManager.selected_action or not player_turn:
		return
	
	get_tree().call_group(&"tiles", "defend", CombatManager.selected_action)
	player_turn = false
	GameGlobalEvents.player_turn.emit()
	CombatManager.current_board.determine_selectables()

func _on_hp_changed() -> void:
	hp_label.text = "HP: %s" % PlayerManager.hp

# TODO: Refactor redundant functions later just need this for function population before collapse
func _on_battle_ended() -> void:
	_on_map_ended()

func _on_game_ended() -> void:
	get_tree().quit()
#endregion
