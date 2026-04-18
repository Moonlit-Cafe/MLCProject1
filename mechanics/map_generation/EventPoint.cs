using Godot;
using Godot.Collections;
using System;
using System.Runtime.InteropServices;

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
	public Array<EventPoint> eventList;
	[Export] public EventType eventType = EventType.BATTLE;
	[Export] public Array<EventConnection> connections = new Array<EventConnection>();
	public Vector2I position = Vector2I.Zero;
	[Export] public float connectionRate = 3.0f;
	[Export] public float toEndRatio = 0.5f;

	public void createConnections(EventPoint endPosition)
	{
		Array<EventPoint> allowedEvents = eventList.Duplicate();
		RandomNumberGenerator rng = new RandomNumberGenerator();
		int connected = 0;
		while (rng.Randf() < connectRate(connected) && allowedEvents.Count > 1)
		{
			EventPoint connectTo;
			if (rng.Randf() < toEndRatio)
			{
				connectTo = determineEventToConnect(allowedEvents, endPosition);
			}
			else
			{
				connectTo = determineEventToConnect(allowedEvents);
			}
			
			allowedEvents.Remove(connectTo);
			EventConnection newConnection = new EventConnection
			{
				connectedPoint = connectTo
			};
			connections.Add(newConnection);
		}
	}

	public EventPoint determineEventToConnect(Array<EventPoint> allowedEvents, EventPoint directTo = null)
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

				Vector2 directToVector = (directTo.position - position);
				Vector2 connectToVector = (connectTo.position - position);
				Vector2 eToVector = (e.position - position);

				if (directToVector.AngleTo(eToVector) < directToVector.AngleTo(connectToVector))
				{
					connectTo = e;
				}
			}
		}

		return connectTo;
	}

	public void sortClosest(int allowedClosest)
	{
		_bubbleSort(eventList);
		if (allowedClosest < eventList.Count)
		{
			while (allowedClosest < eventList.Count)
			{
				eventList.RemoveAt(allowedClosest - 1);
			}
		}
	}

	private void _bubbleSort(Array<EventPoint> events)
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

	private float connectRate(int connected)
	{
		return (float) (1f / Math.Pow(connectionRate, Math.Max(0, connected - 1)));
	}
}
