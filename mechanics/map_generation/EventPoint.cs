using Godot;
using Godot.Collections;

namespace CraftingCrawler.mechanics.map_generation;

[GlobalClass]
public partial class EventPoint : Resource
{
	public enum EventType
	{
		Start,
		BossBattle,
		Battle,
		Shop,
		Unique
	}
	[Export] public StringName EventID = "New ID";

	[Export]
	public Dictionary EventTypeMap { get; private set; } = new()
	{
		{"START", (int)EventType.Start},
		{"BOSS_BATTLE", (int)EventType.BossBattle},
		{"BATTLE", (int)EventType.Battle},
		{"SHOP", (int)EventType.Shop},
		{"UNIQUE", (int)EventType.Unique}
	};

	[Export] public EventType Type = EventType.Battle;
	[Export] public Array<EventPoint> ConnectionsTo = [];
	[Export] public Array<EventPoint> ConnectionsFrom = [];
	[Export] public PackedScene Scene;
}