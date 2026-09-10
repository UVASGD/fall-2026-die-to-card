class_name UnitData
extends Resource

### Stores data regarding units for loading in encounters, across combat scenes

## UID for the unit's "base" scene
@export var unit_uid : String
@export var name : String
@export var max_health : int
@export var speed : int
@export var defense : int
@export var auto_card : ActionCard
@export var cost : int
