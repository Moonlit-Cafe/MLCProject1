class_name HealthConsideration extends Consideration

#region Events
func score(entity: TileEntity) -> float:
	return response.sample(entity.health.remaining_amount)
#endregion
