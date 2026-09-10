class_name CombatEncounter
extends Encounter

### Parent class for combat encounter resources
## to create a new combat encounter, make a resource inheriting from this script

@export var terrain_map : TerrainMap
@export var enemy_playset : Playset
@export var enemy_health : int
