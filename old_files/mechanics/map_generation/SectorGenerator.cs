using Godot;
using Godot.Collections;

namespace CraftingCrawler.mechanics.map_generation;

[GlobalClass]
public partial class SectorGenerator : Node
{
	#region Declarations
	[Export] public Array<EventRule> Rules = [];
	[Export] public int ConnectionsPerEvent = 2;
	[Export] public bool PerIO;
	[Export] public Vector2I NodeBoard;
	[Export] public Dictionary<EventPoint.EventType, Array<PackedScene>> EventSceneRef = [];
	[Export] public Array<Array<EventPoint>> EventList = [];
	#endregion

	#region Events
	// ReSharper disable once MemberCanBePrivate.Global
	public void GenerateEvents()
	{
		EventList = [];

		var eventIdx = 0;
		for (var y = 0; y < NodeBoard.Y; y++)
		{
			Array<EventPoint> eventRow = [];
			for (var x = 0; x < NodeBoard.X; x++)
			{
				EventPoint ev = new()
				{
					EventID=$"EV_{eventIdx}",
					Type=EventPoint.EventType.Battle
				};
				eventRow.Add(ev);
				eventIdx++;
			}
			EventList.Add(eventRow);
		}

		SetRules();
		GenerateConnections();
		CheckRules();
		SetScenes();
	}

	private void SetRules()
	{
		Array<EventRule> setRules = [];
		foreach (var rule in Rules)
		{
			if (rule.Rule == EventRule.RuleType.Set)
			{
				setRules.Add(rule);
			}
		}
		
		foreach(var rule in setRules)
		{
			foreach (var point in EventList[rule.LayerNum])
			{
				point.Type = rule.EventType;
				if (!EventSceneRef.TryGetValue(rule.EventType, out var value)) continue;
				if (value.Count != 0)
				{
					point.Scene = EventSceneRef[rule.EventType].PickRandom();
				}
			}
		}
	}

	private void GenerateConnections()
	{
		var rowPos = 0;
		foreach (var eventRow in EventList)
		{
			foreach(var ev in eventRow)
			{
				var connectCount = ConnectionsPerEvent;
				if (rowPos + 1 >= EventList.Count)
				{
					continue;
				}

				var nextRow = EventList[rowPos + 1];
				if (!PerIO)
				{
					connectCount -= ev.ConnectionsFrom.Count;
				}

				while (connectCount > 0)
				{
					var nextEvent = nextRow.PickRandom(); //Change this to a global RNG later
					if (nextEvent.ConnectionsFrom.Count > ConnectionsPerEvent ||
						ev.ConnectionsTo.Contains(nextEvent)) continue;
					nextEvent.ConnectionsFrom.Add(ev);
					ev.ConnectionsTo.Add(nextEvent);
					connectCount--;
				}
			}

			if (rowPos + 1 < EventList.Count)
			{
				Array<EventPoint> emptiedRow = [];
				foreach(var ev in EventList[rowPos + 1])
				{
					if (ev.ConnectionsFrom.Count != 0)
					{
						emptiedRow.Add(ev);
					}
				}
				EventList[rowPos + 1] = emptiedRow;
			}
			rowPos++;
		}
	}

	private void CheckRules()
	{
		
	}

	private void SetScenes()
	{
		foreach (var eventRow in EventList)
		{
			foreach(var ev in eventRow)
			{
				if (!EventSceneRef.ContainsKey(ev.Type))
				{
					GD.PushWarning($"@SectorGenerator: There is no reference to EventType {ev.Type}");
					continue;
				}
				ev.Scene = EventSceneRef[ev.Type].PickRandom();
			}
		}
	}
	#endregion
}
