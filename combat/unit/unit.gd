class_name Unit
extends Node2D

### Manages unit functions for combat encounters
## NOTICE: actual movement on the grid is handled by the CombatGrid

#WARNING: when instancing a unit scene, please remember to replace the unit data
#         of the instance, the unit data here is generic (default)

enum INTENT_TYPE {
	NULL, #this is just default or no type, I couldn't come up with a better name
	ATTACK,
	DEFEND,
	HEAL,
	MOVE
}

@export var unit_data : UnitData
#this is the display for the unit in the unit selection gui
@export var select_icon : Texture2D = null #NOTE: we could also make this animation later...
@export var intent_display : UnitIntentsDisplay = null
var health : int
var location : Vector2i
var statuses : Array[String] #TODO: make this work when I setup buffs/debuffs
var enemy : bool = false
var intent_card : ActionCard = null

func take_damage(damage : int):
	var new_health = max(0,health - damage)
	if new_health == 0:
		die()

func die(): #TODO: fill in death animation trigger
	CombatManager.combat_grid.unit_grid.erase(location)
	queue_free()

func heal(healing: int):
	health = min(unit_data.max_health,health + healing)

func deploy(coords : Vector2i):
	CombatManager.combat_grid.add_child(self)
	CombatManager.combat_grid.move_unit(self,coords,true)
