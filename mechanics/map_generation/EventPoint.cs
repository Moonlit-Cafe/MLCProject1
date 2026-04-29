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

	public Array<EventPoint> eventList;
	[Export] public EventType eventType = EventType.BATTLE;
	[Export] public Array<EventConnection> connections = new Array<EventConnection>();
	public Vector2I position = Vector2I.Zero;
	[Export] public float connectionRate = 3.0f;
	[Export] public float toEndRatio = 0.5f;
	[Export] public EventHolder eventRef;

	public void CreateConnections(EventPoint endPosition)
	{
		Array<EventPoint> allowedEvents = eventList.Duplicate();
		RandomNumberGenerator rng = new();
		int connected = 0;
		while (rng.Randf() < ConnectRate(connected) && allowedEvents.Count > 1)
		{
			EventPoint connectTo;
			if (rng.Randf() < toEndRatio)
			{
				connectTo = DetermineEventToConnect(allowedEvents, endPosition);
			}
			else
			{
				connectTo = DetermineEventToConnect(allowedEvents);
			}
			
			allowedEvents.Remove(connectTo);
			EventConnection newConnection = new EventConnection
			{
				connectedPoint = connectTo
			};
			connections.Add(newConnection);
		}
	}

	public EventPoint DetermineEventToConnect(Array<EventPoint> allowedEvents, EventPoint directTo = null)
	{
		EventPoint connectTo = null;
		if (directTo == null)
		{
			connectTo = allowedEvents.PickRandom();
		}
		else
		{
			foreach (EventPoint e in allowedEvents)
			{
				if (connectTo == null)
				{
					connectTo = e;
					continue;
				}

				Vector2 directToVector = directTo.position - position;
				Vector2 connectToVector = connectTo.position - position;
				Vector2 eToVector = e.position - position;

				if (directToVector.AngleTo(eToVector) < directToVector.AngleTo(connectToVector))
				{
					connectTo = e;
				}
			}
		}

		return connectTo;
	}

	public void SortClosest(int allowedClosest)
	{
		if (eventList.Contains(this))
		{
			eventList.Remove(this);
		}

		BubbleSort(eventList);
		if (allowedClosest < eventList.Count)
		{
			while (allowedClosest < eventList.Count)
			{
				eventList.RemoveAt(allowedClosest - 1);
			}
		}
	}

	private void BubbleSort(Array<EventPoint> events)
	{
		int n = events.Count - 1;
		int i, j;
		EventPoint temp;
		bool swapped;
		for (i = 0; i < n; i++)
		{
			swapped = false;
			for (j = 0; j < (n - i); j++)
			{
				if (events[j].position.DistanceTo(position) > events[j + 1].position.DistanceTo(position))
				{
					temp = events[j];
					events[j] = events[j + 1];
					events[j + 1] = temp;
					swapped = true;
				}
			}

			if (swapped == false)
			{
				break;
			}
		}
	}

	private float ConnectRate(int connected)
	{
		return (float) (1f / Math.Pow(connectionRate, Math.Max(0, connected - 1)));
	}
}
