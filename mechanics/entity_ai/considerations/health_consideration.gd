class_name HealthConsideration extends Consideration

#region Events
func supports(target: Variant) -> bool:
	return target is TileEntity

func score(entity: TileEntity) -> float:
	return response.sample(entity.health.remaining_amount)
#endregion
