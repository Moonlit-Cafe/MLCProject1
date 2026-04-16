using Godot;

[GlobalClass]
public partial class EventConnection : Resource
{
	public EventPoint connectedPoint;
	public bool biDirectional = true;
}
