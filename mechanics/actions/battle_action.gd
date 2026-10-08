class_name BattleAction extends BaseAction
##Class that describes an action that can be taken during in-game battle

#region Declarations
@export_category("Target Effects")
@export var flats : Array[FlatStatChange]
@export var temps: Array[TempStatChange]
@export var effects : Array[EffectChange]


@export_category("Target Movement")
@export var pushback : RelativePlaceChange
@export var displace : DirectPlaceChange

@export_category("Source Effects")
@export var flat_costs : Array[FlatStatChange] ## Uses [class FlatStatChange] similar to flats, but specifically
## to target Aether, Stamina, and etc.
@export var temp_costs : Array[TempStatChange]
@export var self_effects : Array[EffectChange]

@export_category("Source Movement")
@export var recoil : RelativePlaceChange
@export var teleport : DirectPlaceChange
#endregion


#region Events
func apply(target:TileEntity, source:TileEntity):
	
	
	if target:
		_apply_target_effects(target)
		_apply_target_moves(target)
		
	if source:
		_apply_source_effects(source)
		_apply_source_moves(source)
		

func _apply_target_effects(target:TileEntity) -> void:
	for flat in flats:
		flat.apply(target)
	for effect in effects:
		effect.apply(target)
	for temp in temps:
		temp.apply(target)
		

func _apply_target_moves(target:TileEntity) -> void:
	if pushback:
		pushback.apply(target)
	if displace:
		displace.apply(target)
		

func _apply_source_effects(source:TileEntity) -> void:
	for flat_cost in flat_costs:
		flat_cost.apply(source)
	for temp_cost in temp_costs:
		temp_cost.apply(source)
	for self_effect in self_effects:
		self_effect.apply(source)

func _apply_source_moves(source:TileEntity) -> void:
	if recoil:
		recoil.apply(source)
	if teleport:
		teleport.apply(source)
#endregion
