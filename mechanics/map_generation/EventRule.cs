using Godot;

[GlobalClass]
public partial class EventRule : Resource
{
    public enum RuleType
    {
        EXCLUDE,
        GENERATE_AFTER,
        GENERATE_BEFORE,
        CANNOT_DOUBLE,
        SET
    }

    [Export] public RuleType rule = RuleType.GENERATE_AFTER;
    [Export] public int layerNum = 0;
    [Export] public EventPoint.EventType eventType = EventPoint.EventType.START;
}