extends Control

#region Exports
@export var p_health : float = 0.0
@export var p_mana : float = 0.0
@export var p_movement : float = 0.0
@export var e_health : float = 0.0
@export var e_mana : float = 0.0
@export var e_movement : float = 0.0

@export var player_unit : UnitBox
@export var enemy_unit : EnemyBox

@export var consideration_log : RichTextLabel

@export var abilities : Array[Ability]

#endregion

var characters:Dictionary = {}


func _ready() -> void:
	characters["player"] = [player_unit.health,player_unit.mana,player_unit.movement]
	characters["enemy"] = [enemy_unit.health,enemy_unit.mana,enemy_unit.movement]
	consideration_log.scroll_following = true
	GameGlobalEvents.act.connect(handle_actions)
	GameGlobalEvents.thinking.connect(print_thought)
	
func print_thought(data:String) -> void :
	consideration_log.append_text(data + "\n")

func handle_actions(data:String = "light", target : String = "player") -> void :
	var action:=Ability.new()
	
	match data :
		"heavy":
			action = $VBoxContainer/HBoxContainer/VBoxContainer/EnemyVbox/ContentContainer/Enemy/Abilities/Heavy
		"magic":
			action = $VBoxContainer/HBoxContainer/VBoxContainer/EnemyVbox/ContentContainer/Enemy/Abilities/Magic
		_:
			action = $VBoxContainer/HBoxContainer/VBoxContainer/EnemyVbox/ContentContainer/Enemy/Abilities/Light
	match target:
		"player": 
			player_unit.health -= action.ac_value
		"enemy":
			if action.ac_name == "magic" :
				if player_unit.mana - action.ac_cost >= 0 :
					player_unit.mana -= action.ac_cost
				else :
					return
			enemy_unit.health -= action.ac_value
			
	if player_unit.health <= 0 or enemy_unit.health <= 0 :
		print("Mission End!")
	
	## DAVE
	#update()
func _on_end_turn_pressed() -> void :
	#consider()
	consideration_log.append_text("\nThinking about my turn...\n")
	## Think for two seconds...
	#await get_tree().create_timer(2.0).timeout
	#var choices = enemy_unit.brain.decide(player_unit)
	#enemy_unit.process_turn(player_unit)


func update() -> void :
	player_unit.update()
	enemy_unit.update()
