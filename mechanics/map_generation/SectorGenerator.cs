using Godot;
using Godot.Collections;

[GlobalClass]
public partial class SectorGenerator : Node
{
	public Array<EventPoint> eventList {get; set;} = new Array<EventPoint>();
	public Vector2I mapSize {get; set;} = new Vector2I(16, 16);
	public Rect2I endArea {get; set;} = new Rect2I(12, 12, 4, 4);
	public Rect2I startArea {get; set;} = new Rect2I(0, 0, 4, 4);

    public override void _Ready()
    {
        base._Ready();
		generateEvents(20);
    }

	public void generateEvents(int eventsToGenerate)
	{
		Array<Vector2I> takenPositions = new Array<Vector2I>();
		for (int i = 0; i < eventsToGenerate; i++)
		{
			Vector2I newPosition = generateEventPosition();
			while (takenPositions.Contains(newPosition))
			{
				newPosition = generateEventPosition();
			}
            EventPoint eventPoint = new EventPoint
            {
                eventType = EventPoint.EventType.BATTLE,
				position = newPosition
            };
            eventList.Add(eventPoint);
		}

		foreach (EventPoint e in eventList)
		{
			e.eventList = eventList.Duplicate();
			e.sortClosest(5); // Currently allowing only the 3 closest events to be considered for sorting end result.
		}

		GD.Print(eventList);
	}

	private Vector2I generateEventPosition()
	{
		var global = GetNode("/root/GameGlobal");
		int x = (int) global.Call("get_random_i", 0, 16);
		int y = (int) global.Call("get_random_i", 0, 16);
		return new Vector2I(x, y);
	}
}
