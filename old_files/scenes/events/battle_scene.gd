### Handles generating the battle, enemies involved and choosing any additional modifiers for generating
### the battle.
#class_name BattleScene extends BaseEventScene
#
##region Declarations
#@export var combat_view_scene : PackedScene
#@export var combat_machine_scene : PackedScene
#@export var combat_machine_holder : Node
#@export var combat_views_layers : CanvasLayer
#
#var enemy_count : int = 0
#var reward_tier : int = 1
#var elite_modifier : float = 1.0
#var special_ability : bool = false
#var boss_type : int = 1
##endregion
#
##region Events
#func _ready() -> void:
	#start_battle()
#
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("divergence"):
		#start_battle(true)
#
#func start_battle(copy:=false) -> void:
	#if combat_machine_holder.get_child_count() >= 2:
		#return
	#
	#var combat_machine : CombatMachine = combat_machine_scene.instantiate() as CombatMachine
	#var new_view : BattleView
	#if copy:
		#var current_battle : BattleView = combat_machine_holder.get_child(0).battle_scene
		#new_view = current_battle.duplicate(DUPLICATE_DEFAULT) as BattleView
	#else:
		#new_view = combat_view_scene.instantiate()
	#var new_container := SubViewportContainer.new()
	#new_container.name = "Battle%s" % combat_views_layers.get_child_count()
	#combat_views_layers.add_child(new_container)
	#new_container.add_child(new_view)
	#combat_machine.battle_scene = new_view
	#combat_machine_holder.add_child(combat_machine)
	#
	#_update_viewports()
#
#func _update_viewports() -> void:
	#match (combat_views_layers.get_child_count()):
		#1:
			#var view : BattleView = combat_machine_holder.get_child(0).battle_scene
			#var container : SubViewportContainer = view.get_parent()
			#_update_anchors(container, Rect2(0, 0, 1., 1.))
			#view.size = container.size
		#2:
			#var view_1 : BattleView = combat_machine_holder.get_child(0).battle_scene
			#var view_2 : BattleView = combat_machine_holder.get_child(1).battle_scene
			#var container_1 : SubViewportContainer = view_1.get_parent()
			#var container_2 : SubViewportContainer = view_2.get_parent()
			#_update_anchors(container_1, Rect2(0, 0, .5, 1.))
			#_update_anchors(container_2, Rect2(.5, 0, .5, 1.))
			#view_1.size = container_1.size
			#view_2.size = container_2.size
		#_:
			#Global.logs.post_warning(self, "Not coded yet for size . . .")
#
#func _update_anchors(control: Control, rect: Rect2) -> void:
	#control.anchor_left = rect.position.x
	#control.anchor_top = rect.position.y
	#control.anchor_right = rect.position.x + rect.size.x
	#control.anchor_bottom = rect.position.y + rect.size.y
##endregion
#
##region Signal Callbacks
#func _on_pressed() -> void:
	## TYLER SceneManager.load_next_scene()
	#return
##endregion
