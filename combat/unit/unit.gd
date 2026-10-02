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

enum UNIT_CLASS {
	NULL, #lack of class (THIS IS IMPORTANT! DON'T DELETE THIS!)
	NONE, #default class
	WARRIOR,
	TANK,
	HEALER,
	SCOUT
}

@export var unit_data : UnitData
#this is the display for the unit in the unit selection gui
@export var select_icon : Texture2D = null #NOTE: we could also make this animation later...
@export var intent_display : UnitIntentsDisplay = null
var health : int
var location : Vector2i
var statuses : Array[String] #TODO: make this work when I setup buffs/debuffs
var enemy : bool = false
var intent_actions : Array[CardAction] = []

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

##displays the intent you desire
func set_intents(actions : Array[CardAction]):
	for i in actions:
		intent_display.display_intent(i.intent_type,i.value)
		intent_actions.append(i)

##remove a specific intents
func remove_intents(actions : Array[CardAction]):
	for i in actions:
		intent_display.clear_intent(i.intent_type,i.value)
		intent_actions.erase(i)

##wipes the intent display clean
func clear_intents():
	intent_display.clear_intents()
	intent_actions.clear()
