using Godot;
using Godot.Collections;

[GlobalClass]
public partial class SectorGenerator : Node
{
	public Array<EventPoint> events;
	public Vector2I mapSize = new Vector2I(16, 16);
	public Rect2I endArea = new Rect2I(12, 12, 4, 4);
	public Rect2I startArea = new Rect2I(0, 0, 4, 4);
}
