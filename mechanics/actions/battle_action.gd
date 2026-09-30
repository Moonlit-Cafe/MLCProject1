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
@export var r_cost : FlatStatChange ## Uses [class FlatStatChange] similar to flats, but specifically
## to target Aether, Stamina, and etc.
@export var temp_cost : Array[TempStatChange]
@export var self_effect : Array[EffectChange]

@export_category("Source Movement")
@export var recoil : RelativePlaceChange
@export var teleport : DirectPlaceChange
#endregion


#region Events
func apply(target_tile:BattleTile, source:TileEntity):
	var target = target_tile
	if target_tile.held_entity:
		for flat in flats:
			flat.apply(target)
		for effect in effects:
			effect.apply(target)
		for temp in temps:
			temp.apply(target)
			

	if source:
		r_cost.apply(source)
#endregion
