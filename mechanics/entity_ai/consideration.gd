@abstract
class_name Consideration extends Resource

#region Declarations
@export var response : Curve
#endregion

#region Events
@abstract func supports(_scored: Variant) -> bool
@abstract func score(_scored) -> float
#endregion
