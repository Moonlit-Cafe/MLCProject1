class_name TileEntity extends Node3D

#region Declarations
@export var sprite : AnimatedSprite3D

var character : CharacterResource
var parent_tile : BattleTile

var resource_type := CombatAction.ResourceType.NONE
var resource : int = 0
var stats : Dictionary[Genum.StatType, float]
#var character : Variant
#var parent_tile : BattleTile
#
#var hp : int = -1 :
#	set(value):
#		#if not held_entity:
#			#return
#		
#		if value <= 0:
#			# PLANNED setup signal instead of double get_parent() call
#			parent_tile.clear_object()
#			hp = -1
#		else:
#			hp = value
#var max_hp : int = 0
#endregion

#region Events
func update() -> void:
	if sprite and char:
		sprite.sprite_frames = character.frames
	
	position = Vector3(0., 8., 0) ## TODO: Need to either settle on an offset, or grab thie from Battle Map
	

func attack(victim: TileEntity, damage: float) -> void:
	# TODO: Need to come back to this for editings
	print(victim.name)
	victim.defend(damage, self)

func defend(damage: float, _offender: TileEntity) -> void:
	var hp = stats.get(Genum.StatType.HEALTH)
	hp -= damage
	stats.set(Genum.StatType.HEALTH, hp)
	if hp <= 0:
		print(self.name)
		parent_tile.clear_object()

func commit_action() -> void:
	var action : Action = null
	if character is EnemyCharacter:
		var available_actions : Array[Action] = []
		var available_scores : Array[float] = []
		for decision_key in character.deciders.keys():
			var target : TileEntity = null
			var decision_set = character.deciders.get(decision_key)
			match (decision_key):
				# TODO: Include the rest
				DeciderHolder.TargetType.SELF:
					target = self
				DeciderHolder.TargetType.PLAYER:
					target = parent_tile.battle_map.player
			var decision = CombatManager.consideration_manager.decide(target, decision_set.deciders)
			available_actions.append(CombatManager.skill_manager.get_action(decision.action))
			print(decision.score(target))
			available_scores.append(decision.score(target))
		
		action = available_actions.get(GameGlobal.rng.rand_weighted(available_scores))
	if action is CombatAction:
		if character is EnemyCharacter:
			var target = parent_tile.battle_map.player
			attack(target, action.value)
	elif action is MoveAction:
		var board := parent_tile.battle_map
		var cur_pos := Vector2i(parent_tile.tile_position.x, parent_tile.tile_position.z)
		var dir = board.dir_to_player(cur_pos)
		if action.towards_player:
			board.board.get(cur_pos + dir).attach_entity(self)
		else:
			board.board.get(cur_pos - dir).attach_entity(self)
	await GameGlobal.delay(0.5)
	parent_tile.turn_finished.emit()
	
func get_stat(stat: Genum.StatType) -> Vector2i:
	return Vector2i(stats.get(stat), character.stats.get(stat))
#endregion
