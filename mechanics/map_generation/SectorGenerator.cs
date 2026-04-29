using System.Drawing;
using System.Linq;
using Godot;
using Godot.Collections;

[GlobalClass]
public partial class SectorGenerator : Node
{
	#region Declarations
	[Export] public Array<EventHolder> eventReference { get; set; } = new Array<EventHolder>();
	[Export] public Vector2I mapSize {get; set;} = new Vector2I(16, 16);
	[Export] public Vector2I areaSize {get; set;} = new Vector2I(4, 4);
	[Export] public bool autoGenerateArea {get; set;} = true;
	[Export] public Rect2I endArea {get; set;} = new Rect2I(12, 12, 4, 4);
	[Export] public Rect2I startArea {get; set;} = new Rect2I(0, 0, 4, 4);
	[Export] public int eventsToGenerate = 20;
	[Export] public int closestToPath = 5;
	[Export] public Dictionary<EventPoint.EventType, float> eventProb = new();
	[Export] public Array<EventPoint> eventList {get; set;} = new Array<EventPoint>();
	#endregion

	#region Events
	public Array<EventPoint> CreateSector()
	{
		eventList = new Array<EventPoint>();

		if (autoGenerateArea)
		{
			GenerateStartEndAreas();
		}
		SetEventProbabilty();
		GenerateEvents(eventsToGenerate);
		GenerateConnections();

		return eventList;
	}

	public void SetEventProbabilty()
	{
		if (eventProb.Count == 0)
		{
			eventProb.Add(EventPoint.EventType.SHOP, 1f);
			eventProb.Add(EventPoint.EventType.BATTLE, 1f);
		}
	}

	public void GenerateEvents(int eventsToGenerate)
	{
		RandomNumberGenerator rng = new();
		EventPoint startEvent = new()
		{
			eventID = "Start Event",
			position = GenerateEventPosition(startArea)
		};
		EventPoint endEvent = new()
		{
			eventID = "End Event",
			position = GenerateEventPosition(endArea)
		};

		eventList.Add(startEvent);
		eventList.Add(endEvent);

		Array<Vector2I> takenPositions = new();
		for (int i = 0; i < eventsToGenerate; i++)
		{
			Vector2I newPosition = GenerateEventPosition(new Rect2I(0, 0, mapSize));
			while (takenPositions.Contains(newPosition))
			{
				newPosition = GenerateEventPosition(new Rect2I(0, 0, mapSize));
			}

			float runningPercent = 0f;
			float eventChance = rng.Randf();
			EventPoint.EventType eventType = EventPoint.EventType.BATTLE;
			foreach (EventPoint.EventType type in eventProb.Keys)
			{
				runningPercent += eventProb[type] / eventProb.Values.Sum();
				if (eventChance < runningPercent)
				{
					eventType = type;
					break;
				}
			}

			EventHolder sceneEvent = null;
			if (eventReference.Count > 0)
			{
				Array<EventHolder> availableEvents = new();
				foreach (EventHolder eventHold in eventReference)
				{
					if (eventHold.eventType == eventType)
					{
						availableEvents.Add(eventHold);
					}
				}

				float sceneTotalWeight = 0f;
				foreach (EventHolder eventHold in availableEvents)
				{
					sceneTotalWeight += eventHold.weight;
				}

				float scenePercent = 0f;
				float sceneChance = rng.Randf();
				foreach (EventHolder eventHold in availableEvents)
				{
					scenePercent += eventHold.weight / sceneTotalWeight;
					if (sceneChance <= scenePercent)
					{
						sceneEvent = eventHold;
						break;
					}
				}
			}

			EventPoint eventPoint = new()
			{
				eventID = $"Event {i}",
				eventType = eventType,
				position = newPosition,
				eventRef = sceneEvent
			};
			eventList.Add(eventPoint);
		}

		foreach (EventPoint e in eventList)
		{
			e.eventList = eventList.Duplicate();
			e.SortClosest(closestToPath); // Currently allowing only the 3 closest events to be considered for sorting end result.
			e.CreateConnections(eventList[1]);
		}
	}

	private void GenerateStartEndAreas()
	{
		startArea = new Rect2I(Vector2I.Zero, areaSize);
		endArea = new Rect2I(mapSize - areaSize, areaSize);
	}

	private Vector2I GenerateEventPosition(Rect2I bounds)
	{
		var global = GetNode("/root/GameGlobal");
		int x = (int) global.Call("get_random_i", bounds.Position.X, bounds.Position.X + bounds.Size.X);
		int y = (int) global.Call("get_random_i", bounds.Position.Y, bounds.Position.Y + bounds.Size.Y);
		Vector2I eventPosition = new(x, y);
		while (IsWithinRect(startArea, eventPosition) || IsWithinRect(endArea, eventPosition))
		{
			x = (int) global.Call("get_random_i", bounds.Position.X, bounds.Position.X + bounds.Size.X);
			y = (int) global.Call("get_random_i", bounds.Position.Y, bounds.Position.Y + bounds.Size.Y);
			eventPosition = new Vector2I(x, y);
		}
		return eventPosition;
	}

	private static bool IsWithinRect(Rect2I rect, Vector2I pos)
	{
		bool within = false;
		if (pos.X > rect.Position.X && pos.X < (rect.Position.X + rect.Size.X))
		{
			if (pos.Y > rect.Position.Y && pos.Y < (rect.Position.Y + rect.Size.Y))
			{
				within = true;
			}
		}
		return within;
	}

	public void GenerateConnections()
	{
		foreach (EventPoint e in eventList)
		{
			e.CreateConnections(eventList[1]);
		}
	}
	#endregion
}
