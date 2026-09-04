@abstract
class_name Consideration extends Resource

#region Declarations
@export var response : Curve
#endregion

#region Events
@abstract func score(_entity: TileEntity) -> float
#endregion
