@tool
class_name CardCreator
extends Control

### Card Creator script. make the cards here.

@export_category("Creator")
@export var resource_name : StringName
@export_tool_button("Save Card","Save") var card_save : Callable = save_card
@export_tool_button("Load Card","Load") var card_load : Callable = load_card
@export_tool_button("Clear Card","Clear") var card_clear : Callable = clear_card
@export_tool_button("Add Action","ScriptCreate") var action_add : Callable = add_action
@export_category("Card")
@export var card_name : String = ""
@export var portrait : Texture = null

@onready var display_card : ActionCardDisplay = $ActionCardDisplay
@onready var action_display : PackedScene = preload("uid://dygcl7f4ktt3v")
@onready var card_creator_action : PackedScene = preload("uid://clobx3wgsqv86")
@onready var card_creator_event : PackedScene = preload("uid://dq05mkc5x84gc")
@onready var action_card_display : PackedScene = preload("uid://b8nnn0fw630u5")

## saving card to resource
func save_card():
	if Engine.is_editor_hint():
		var new_ac : ActionCard = ActionCard.new()
		new_ac.name = card_name
		new_ac.portrait = portrait
		for i in get_children():
			#forming actions
			if i is CardCreatorAction:
				var action : Dictionary = {}
				action.set("value",i.value)
				action.set("intent",i.intent)
				action.set("text",i.text)
				action.set("focus",false)
				var diceslot : Dictionary = {}
				diceslot.set("dice",null)
				action.set("diceslot",diceslot)
				new_ac.actions.set(i.action_name,action)
			elif i is CardCreatorEvent:
				var event : Dictionary[String,Dictionary] = {}
				event.set("text",i.text)
				event.set("command",i.command)
				event.set("arguments",i.arguments)
				new_ac.events.set(i.event_name,event)
		var error : Error = ResourceSaver.save(new_ac,"res://data/cards/"+String(resource_name)+".tres")
		if error != Error.OK:
			print(error)

## WARNING: save_card, THEN load_card to view your changes
## loading resource to display card (for your viewing pleasure)
func load_card():
	if Engine.is_editor_hint():
		var loaded_card : ActionCard = load("res://data/cards/"+String(resource_name)+".tres")
		display_card = _load_card_display()
		display_card.action_card = loaded_card
		display_card.load_display()
		for i in get_children():
			if i is CardCreatorAction:
				i.queue_free()
		for i in loaded_card.actions.keys():
			var old_action : Dictionary = loaded_card.actions.get(i)
			var new_action = add_action()
			new_action.action_name = i
			new_action.value = old_action.get("value")
			new_action.intent = old_action.get("intent")
			new_action.text = old_action.get("text")
			#var diceslot : Dictionary = old_action.get("diceslot")
			#TODO: dice stuff when I get that all setup
		for i in loaded_card.events.keys():
			var old_event : Dictionary = loaded_card.events.get(i)
			var new_event = add_event()
			new_event.event_name = i
			new_event.command = old_event.get("command")
			new_event.arguments = old_event.get("arguments")
			new_event.text = old_event.get("text")

## clean wipe up
func clear_card():
	if Engine.is_editor_hint():
		display_card = _load_card_display()
		#make it show up in editor scene
		display_card.set_owner(get_tree().edited_scene_root)
		for i in get_children():
			if i is CardCreatorAction or i is CardCreatorEvent:
				i.queue_free()

## does what is says it does :)
func add_action() -> CardCreatorAction:
	if Engine.is_editor_hint():
		var action : CardCreatorAction = card_creator_action.instantiate()
		add_child(action,true)
		#make it show up in editor scene
		action.set_owner(get_tree().edited_scene_root)
		return action
	return null

## also does what it says it does
func add_event() -> CardCreatorEvent:
	if Engine.is_editor_hint():
		var event : CardCreatorEvent = card_creator_event.instantiate()
		add_child(event,true)
		event.set_owner(get_tree().edited_scene_root)
		return event
	return null

## loads up new display card scene for previewing
func _load_card_display() -> ActionCardDisplay:
	if display_card:
		display_card.queue_free()
	var new_display : ActionCardDisplay = action_card_display.instantiate()
	add_child(new_display,true)
	new_display.set_owner(get_tree().edited_scene_root)
	for i in new_display.get_children(true):
		i.set_owner(get_tree().edited_scene_root)
	return new_display
