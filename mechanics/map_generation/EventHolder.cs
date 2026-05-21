using Godot;

[GlobalClass]
public partial class EventHolder : Resource
{
    [Export] public StringName scene_name = "";
    [Export] public EventPoint.EventType eventType = EventPoint.EventType.START;
    [Export] public PackedScene scene;
    [Export] public float weight;
    int eventIdx = 0;
}