using Godot;

[GlobalClass]
public partial class EventConnection : Resource
{
	[Export] public EventPoint connectedPoint;
	[Export] public bool biDirectional = true;
}
