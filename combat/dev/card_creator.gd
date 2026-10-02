@tool
class_name CardCreator
extends Control

### Card Creator script. make the cards here.

@export_category("Creator")
@export var resource_name : StringName
@export_tool_button("Save Card","Save") var card_save : Callable = _save_card
@export_tool_button("Load Card","Load") var card_load : Callable = _load_card
@export_tool_button("Clear Card","Clear") var card_clear : Callable = _clear_card
@export_tool_button("Add Action","ScriptCreate") var action_add : Callable = _add_creator_action
@export_category("Card")
@export var card_name : String = ""
@export var portrait : Texture = null
#null card_class is for event only cards!
@export var card_class : Unit.UNIT_CLASS = Unit.UNIT_CLASS.NULL

@onready var display_card : ActionCardDisplay = $ActionCardDisplay
@onready var action_display : PackedScene = preload("uid://dygcl7f4ktt3v")
@onready var card_creator_action : PackedScene = preload("uid://clobx3wgsqv86")
@onready var action_card_display : PackedScene = preload("uid://b8nnn0fw630u5")

## saving card to resource
func _save_card():
	if Engine.is_editor_hint():
		var new_ac : ActionCard = ActionCard.new()
		new_ac.name = card_name
		new_ac.portrait = portrait
		new_ac.card_class = card_class
		for i in get_children():
			#forming actions
			if i is CardCreatorAction:
				new_ac.actions.set(i.action_name,i.card_action)
		var error : Error = ResourceSaver.save(new_ac,"res://data/cards/"+String(resource_name)+".tres")
		if error != Error.OK:
			print(error)

## WARNING: save_card, THEN load_card to view your changes
## loading resource to display card (for your viewing pleasure)
func _load_card():
	if Engine.is_editor_hint():
		var loaded_card : ActionCard = load("res://data/cards/"+String(resource_name)+".tres")
		display_card = _load_card_display()
		display_card.action_card = loaded_card
		display_card.load_display()
		card_name = loaded_card.name
		portrait = loaded_card.portrait
		card_class = loaded_card.card_class
		for i in get_children():
			if i is CardCreatorAction:
				i.queue_free()
		for i in loaded_card.actions.keys():
			var new_action = _add_creator_action()
			new_action.action_name = i
			new_action.card_action = loaded_card.actions.get(i)

## clean wipe up
func _clear_card():
	if Engine.is_editor_hint():
		display_card = _load_card_display()
		#make it show up in editor scene
		display_card.set_owner(get_tree().edited_scene_root)
		for i in get_children():
			if i is CardCreatorAction:
				i.queue_free()

## does what is says it does :)
func _add_creator_action() -> CardCreatorAction:
	if Engine.is_editor_hint():
		var action : CardCreatorAction = card_creator_action.instantiate()
		add_child(action,true)
		#make it show up in editor scene
		action.set_owner(get_tree().edited_scene_root)
		return action
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
