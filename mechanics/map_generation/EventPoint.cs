using Godot;
using Godot.Collections;
using System;

[GlobalClass]
public partial class EventPoint : Resource
{
	public enum EventType
	{
		START,
		BOSS_BATTLE,
		BATTLE,
		SHOP,
		UNIQUE
	}
	[Export] public StringName eventID = "New ID";

	[Export]
	public Dictionary EventTypeMap { get; private set; } = new Dictionary
	{
		{"START", (int)EventType.START},
		{"BOSS_BATTLE", (int)EventType.BOSS_BATTLE},
		{"BATTLE", (int)EventType.BATTLE},
		{"SHOP", (int)EventType.SHOP},
		{"UNIQUE", (int)EventType.UNIQUE}
	};

	[Export] public EventType eventType = EventType.BATTLE;
	[Export] public Array<EventPoint> connectionsTo = [];
	[Export] public Array<EventPoint> connectionsFrom = [];
	[Export] public PackedScene scene;
}
