class_name Playset
extends Resource

### Resource that stores an entity's dice, units, and cards for combat

@export var units : Array[UnitData] = []
@export var deck : Array[ActionCard] = []
@export var dice : Array[String] = [] #TODO: replace when make dice
