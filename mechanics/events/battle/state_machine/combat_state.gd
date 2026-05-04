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
	combat_scene = owner.combat_scene
#endregion
