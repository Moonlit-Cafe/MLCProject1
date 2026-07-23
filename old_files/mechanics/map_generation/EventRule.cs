using Godot;

namespace CraftingCrawler.mechanics.map_generation;

[GlobalClass]
public partial class EventRule : Resource
{
    public enum RuleType
    {
        Exclude,
        GenerateAfter,
        GenerateBefore,
        CannotDouble,
        Set
    }

    [Export] public RuleType Rule = RuleType.GenerateAfter;
    [Export] public int LayerNum = 0;
    [Export] public EventPoint.EventType EventType = EventPoint.EventType.Start;
}