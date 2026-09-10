class_name UnitIntentsDisplay
extends Control

### Handles displaying intents and their values (strengths, what have you)
## this should be instansitated for every unit, but other than that should
## just work without much input...
## see CombatIntentDisplay for individual intent functionality

# NOTE: this should be tweaked at some point to make it look nicer...

var intent_stack : Array[IntentDisplay] = []
@onready var intent_scene : PackedScene = preload("uid://bo5hx1dgsgpgl")
@onready var v_box: VBoxContainer = $VBox

func _ready() -> void:
	for i : IntentDisplay in v_box.get_children():
		intent_stack.append(i)
	clear_intents() #just in case :)

func display_intent(intent_type : Unit.INTENT_TYPE, value : int):
	var new_intent : IntentDisplay = intent_scene.instantiate()
	new_intent.set_intent(intent_type,value)
	intent_stack.append(intent_type)
	v_box.add_child(new_intent)

func clear_intent(intent_type : Unit.INTENT_TYPE, value : int):
	for i : IntentDisplay in intent_stack:
		if i.intent_type == intent_type:
			if i.value == value:
				i.queue_free()
				intent_stack.erase(i)
				return

func clear_intents():
	for i in intent_stack:
		i.queue_free()
	intent_stack.clear()
