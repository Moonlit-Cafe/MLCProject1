class_name CombatState extends State

#region Declarations
const INIT : StringName = &"Init"
const ENTITY_TURN : StringName = &"EntityTurn"
const TILE_COND : StringName = &"TileConditions"
const END_COND : StringName = &"EndConditions"

var combat_scene : BattleScene
#endregion

#region Events
func _ready() -> void:
	await owner.ready
	combat_scene = owner.battle_scene
#endregion
