class_name UnitData
extends Resource

### Stores data regarding units for loading in encounters, across combat scenes

## UID for the unit's "base" scene
@export var unit_uid : String
@export var name : String
@export var max_health : int
@export var speed : int
@export var defense : int
##luck should be between 0 and 1, 1 being a 100% chance to get lucky
@export var luck : float = 0.0
@export var auto_action : CardAction
@export var cost : int
@export var unit_class : Unit.UNIT_CLASS = Unit.UNIT_CLASS.NONE
@export var intent_slots : int = 1
@export var is_enemy : bool = false
