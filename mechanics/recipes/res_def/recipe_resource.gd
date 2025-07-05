## Holds the data for a specific recipe.
class_name Recipe extends Resource

## The amount of mats required for the recipe, where current format is:
## Cloth, Leather, Wood, Metal, Dust, Core, BossMaterial
@export var item_costs : Array[int]
@export var result : Item
