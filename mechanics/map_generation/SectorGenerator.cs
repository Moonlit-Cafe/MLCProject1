using System.Linq;
using System.Runtime.CompilerServices;
using System.Text.RegularExpressions;
using Godot;
using Godot.Collections;

[GlobalClass]
public partial class SectorGenerator : Node
{
	#region Declarations
	[Export] public Array<EventRule> rules = [];
	[Export] public int connectionsPerEvent = 2;
	[Export] public bool perIO = false;
	[Export] public Vector2I nodeBoard = new(5, 12);
	[Export] public Dictionary<EventPoint.EventType, Array<PackedScene>> eventSceneRef = [];
	[Export] public Array<Array<EventPoint>> eventList = [];
	#endregion

	#region Events
	public void GenerateEvents()
	{
		eventList = [];

		int eventIdx = 0;
		for (int y = 0; y < nodeBoard.Y; y++)
		{
			Array<EventPoint> eventRow = [];
			for (int x = 0; x < nodeBoard.X; x++)
			{
				EventPoint ev = new()
				{
					eventID=$"EV_{eventIdx}",
					eventType=EventPoint.EventType.BATTLE
				};
				eventRow.Add(ev);
				eventIdx++;
			}
			eventList.Add(eventRow);
		}

		SetRules();
		GenerateConnections();
		CheckRules();
		SetScenes();
	}

	private void SetRules()
	{
		Array<EventRule> setRules = [];
		foreach (EventRule rule in rules)
		{
			if (rule.rule == EventRule.RuleType.SET)
			{
				setRules.Add(rule);
			}
		}
		
		foreach(EventRule rule in setRules)
		{
			foreach (EventPoint point in eventList[rule.layerNum])
			{
				point.eventType = rule.eventType;
				if (!eventSceneRef.ContainsKey(rule.eventType)) continue;
				if (eventSceneRef[rule.eventType].Count() > 0)
				{
					point.scene = eventSceneRef[rule.eventType].PickRandom();
				}
			}
		}
	}

	private void GenerateConnections()
	{
		int rowPos = 0;
		foreach (Array<EventPoint> eventRow in eventList)
		{
			foreach(EventPoint ev in eventRow)
			{
				int connectCount = connectionsPerEvent;
				if (rowPos + 1 >= eventList.Count())
				{
					continue;
				}

				Array<EventPoint> nextRow = eventList[rowPos + 1];
				if (!perIO)
				{
					connectCount -= ev.connectionsFrom.Count();
				}

				while (connectCount > 0)
				{
					EventPoint nextEvent = nextRow.PickRandom(); //Change this to a global RNG later
					if (nextEvent.connectionsFrom.Count() <= connectionsPerEvent && !ev.connectionsTo.Contains(nextEvent))
					{
						nextEvent.connectionsFrom.Add(ev);
						ev.connectionsTo.Add(nextEvent);
						connectCount--;
					}
				}
			}

			if (rowPos + 1 < eventList.Count())
			{
				Array<EventPoint> emptiedRow = [];
				foreach(EventPoint ev in eventList[rowPos + 1])
				{
					if (ev.connectionsFrom.Count() > 0)
					{
						emptiedRow.Add(ev);
					}
				}
				eventList[rowPos + 1] = emptiedRow;
			}
			rowPos++;
		}
	}

	private void CheckRules()
	{
		
	}

	private void SetScenes()
	{
		foreach (Array<EventPoint> eventRow in eventList)
		{
			foreach(EventPoint ev in eventRow)
			{
				if (!eventSceneRef.ContainsKey(ev.eventType))
				{
					GD.PushWarning($"@SectorGenerator: There is no reference to EventType {ev.eventType}");
					continue;
				}
				ev.scene = eventSceneRef[ev.eventType].PickRandom();
			}
		}
	}
	#endregion
}
