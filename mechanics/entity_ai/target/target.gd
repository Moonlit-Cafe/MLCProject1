## The base class for the target system, as an abstract, it's not used itself.
@abstract
class_name Target extends Resource

#region Events
@abstract func locate(origin: TileEntity)
#endregion
