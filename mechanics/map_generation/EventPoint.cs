using Godot;
using Godot.Collections;
using System;

[GlobalClass]
public partial class EventPoint : Resource
{
	public enum EventType
	{
		BATTLE,
		SHOP,
		UNIQUE
	}
	public Array<EventPoint> eventList;
	public EventType eventType = EventType.BATTLE;
	public Array<EventConnection> connections;
	public Vector2I position = Vector2I.Zero;

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
}
