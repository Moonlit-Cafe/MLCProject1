using System.Drawing;
using System.Linq;
using Godot;
using Godot.Collections;

[GlobalClass]
public partial class SectorGenerator : Node
{
	#region Declarations
	[Export] public Vector2I mapSize {get; set;} = new Vector2I(16, 16);
	[Export] public Vector2I areaSize {get; set;} = new Vector2I(4, 4);
	[Export] public bool autoGenerateArea {get; set;} = true;
	[Export] public Rect2I endArea {get; set;} = new Rect2I(12, 12, 4, 4);
	[Export] public Rect2I startArea {get; set;} = new Rect2I(0, 0, 4, 4);
	[Export] public int eventsToGenerate = 20;
	[Export] public int closestToPath = 5;
	[Export] public Dictionary<EventPoint.EventType, float> eventProb = new Dictionary<EventPoint.EventType, float>();
	[Export] public Array<EventPoint> eventList {get; set;} = new Array<EventPoint>();
	#endregion

	#region Events
    public override void _Ready()
    {
        base._Ready();
		if (autoGenerateArea)
		{
			generateStartEndAreas();
		}
		setEventProbabilty();
		generateEvents(eventsToGenerate);
		generateConnections();
    }

	public void setEventProbabilty()
	{
		eventProb.Add(EventPoint.EventType.SHOP, 1f);
		eventProb.Add(EventPoint.EventType.BATTLE, 1f);
	}

	public void generateEvents(int eventsToGenerate)
	{
		RandomNumberGenerator rng = new RandomNumberGenerator();
		EventPoint startEvent = new EventPoint
		{
			position = generateEventPosition(startArea)
		};
		EventPoint endEvent = new EventPoint
		{
			position = generateEventPosition(endArea)
		};

		eventList.Add(startEvent);
		eventList.Add(endEvent);

		Array<Vector2I> takenPositions = new Array<Vector2I>();
		for (int i = 0; i < eventsToGenerate; i++)
		{
			Vector2I newPosition = generateEventPosition(new Rect2I(0, 0, mapSize));
			while (takenPositions.Contains(newPosition))
			{
				newPosition = generateEventPosition(new Rect2I(0, 0, mapSize));
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

            EventPoint eventPoint = new EventPoint
            {
                eventType = eventType,
				position = newPosition
            };
            eventList.Add(eventPoint);
		}

		foreach (EventPoint e in eventList)
		{
			e.eventList = eventList.Duplicate();
			e.sortClosest(closestToPath); // Currently allowing only the 3 closest events to be considered for sorting end result.
		}
	}

	private void generateStartEndAreas()
	{
		startArea = new Rect2I(Vector2I.Zero, areaSize);
		endArea = new Rect2I(mapSize - areaSize, areaSize);
	}

	private Vector2I generateEventPosition(Rect2I bounds)
	{
		var global = GetNode("/root/GameGlobal");
		int x = (int) global.Call("get_random_i", bounds.Position.X, bounds.Position.X + bounds.Size.X);
		int y = (int) global.Call("get_random_i", bounds.Position.Y, bounds.Position.Y + bounds.Size.Y);
		Vector2I eventPosition = new Vector2I(x, y);
		while (isWithinRect(startArea, eventPosition) || isWithinRect(endArea, eventPosition))
		{
			x = (int) global.Call("get_random_i", bounds.Position.X, bounds.Position.X + bounds.Size.X);
			y = (int) global.Call("get_random_i", bounds.Position.Y, bounds.Position.Y + bounds.Size.Y);
			eventPosition = new Vector2I(x, y);
		}
		return eventPosition;
	}

	private bool isWithinRect(Rect2I rect, Vector2I pos)
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

	public void generateConnections()
	{
		foreach (EventPoint e in eventList)
		{
			e.createConnections(eventList[1]);
		}
	}
	#endregion
}
