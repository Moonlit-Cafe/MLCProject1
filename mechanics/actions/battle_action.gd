class_name BattleAction extends BaseAction
##Class that describes an action that can be taken during in-game battle

#region Declarations
@export_category("Target Effects")
@export var flats : Array[FlatStatChange]
@export var temps: Array[TempStatChange]
@export var effects : Array[EffectChange]


@export_category("Target Movement")
@export var pushback : RelativeMove
@export var displace : DirectMove

@export_category("Source Effects")
@export var flat_costs : Array[FlatStatChange] ## Uses [class FlatStatChange] similar to flats, but specifically
## to target Aether, Stamina, and etc.
@export var temp_costs : Array[TempStatChange]
@export var self_effects : Array[EffectChange]

@export_category("Source Movement")
@export var recoil : RelativeMove
@export var teleport : DirectMove
#endregion


#region Events
func apply(target_tile:BattleTile, source:TileEntity):
	var target = target_tile.held_entity
	if target:
		_apply_target_effects(target)
		_apply_target_moves(target_tile, target)
		
	if source:
		_apply_source_effects(source)
		_apply_source_moves(target_tile, source)
		

func _apply_target_effects(target:TileEntity) -> void:
	for flat in flats:
		flat.apply(target)
	for effect in effects:
		effect.apply(target)
	for temp in temps:
		temp.apply(target)
		

func _apply_target_moves(target_tile:BattleTile, target:TileEntity) -> void:
	if pushback:
		pushback.apply(target_tile, target)
	if displace:
		displace.apply(target_tile, target)
		

func _apply_source_effects(source:TileEntity) -> void:
	for flat_cost in flat_costs:
		flat_cost.apply(source)
	for temp_cost in temp_costs:
		temp_cost.apply(source)
	for self_effect in self_effects:
		self_effect.apply(source)

func _apply_source_moves(target_tile:BattleTile, source:TileEntity) -> void:
	if recoil:
		recoil.apply(target_tile, source)
	if teleport:
		teleport.apply(target_tile, source)
#endregion
