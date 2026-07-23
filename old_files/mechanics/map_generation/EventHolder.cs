using Godot;

namespace CraftingCrawler.mechanics.map_generation;

[GlobalClass]
public partial class EventHolder : Resource
{
	[Export] public StringName SceneName = "";
	[Export] public EventPoint.EventType EventType = EventPoint.EventType.Start;
	[Export] public PackedScene Scene;
	[Export] public float Weight;
	private int _eventIdx = 0;
}
