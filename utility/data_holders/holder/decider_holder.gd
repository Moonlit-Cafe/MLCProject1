class_name DeciderHolder extends Resource

#region exports
enum TargetType {
	SELF,
	TILE,
	PLAYER,
	ENEMY,
	ALLY
}

@export var target_type : TargetType = TargetType.PLAYER
@export var action : StringName
@export var target_stat := Genum.StatType.HEALTH
@export var response : Curve
@export var mod : float = 1
#endregion

#region from Abstract Parent
@warning_ignore_start("integer_division")
func score(unit: TileEntity) -> float:
	if not response:
		return -1.
	
	return response.sample_baked(unit.stats.get(target_stat) * mod)
@warning_ignore_restore("integer_division")
#endregion
	
