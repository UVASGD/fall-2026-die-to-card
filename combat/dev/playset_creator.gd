@tool
class_name PlaysetCreator
extends Control

### Script for the creator used to make playeset resources
## Playsets consist of a deck of actioncards, units, and dice

## ADDING CARDS:
## 1) Click add card button
## 2) Attach action card resource to creator card
## 3) Profit (click the load cards button) 

## ADDING UNITS:
## 1) Attach Unit Scene to UnitContainer (Drag n Drop it in)

## ADDING DICE:
## 1) make dice first TODO this

# This can be used both for player playsets and combat encounter playsets

@export_category("Cards")
@export_tool_button("Add Card","ScriptCreate") var card_add : Callable = add_card
@export_tool_button("Load Cards","Load") var cards_load : Callable = load_cards
@export_tool_button("Clear Cards","Clear") var cards_clear : Callable = clear_cards
@export_category("Units")
@export_tool_button("Add Unit","ScriptCreate") var unit_add : Callable = add_unit
@export_tool_button("Load Units","Load") var units_load : Callable = load_units
@export_tool_button("Clear Units","Clear") var units_clear : Callable = clear_units
@export_category("Dice")
@export_tool_button("Clear Dice","Clear") var dice_clear : Callable = clear_dice
@export_category("Playset Resource")
@export var resource_name : String = ""
@export_tool_button("Clear All","Clear") var all_clear : Callable = clear_all
@export_tool_button("Save Playset","Save") var playset_save : Callable = save_playset
@export_tool_button("Load Playset","Load") var playset_load : Callable = load_playset

@onready var card_container : HFlowContainer = $DisplayHolder/CardContainer
@onready var unit_container : HFlowContainer = $DisplayHolder/UnitContainer
@onready var dice_container : HFlowContainer = $DisplayHolder/DiceContainer
@onready var creator_card_holder : Node = $CreatorCardHolder
@onready var creator_unit_holder : Node = $CreatorUnitHolder
@onready var creator_unit : PackedScene = preload("uid://de0bmrbxmr01y")
@onready var creator_card : PackedScene = preload("uid://b3xsaatsnykpn")
@onready var card_display : PackedScene = preload("uid://b8nnn0fw630u5")

#region cards
## add a creator card to the holder
func add_card() -> PlaysetCreatorCard:
	if Engine.is_editor_hint():
		var new_creator_card : PlaysetCreatorCard = creator_card.instantiate()
		creator_card_holder.add_child(new_creator_card,true)
		new_creator_card.set_owner(get_tree().edited_scene_root)
		return new_creator_card
	return null

## this is just for previewing, does not actually influence the playset resource
func load_cards():
	if Engine.is_editor_hint():
		for i in creator_card_holder.get_children():
			if i is PlaysetCreatorCard:
				for j in range(i.quantity):
					var new_display : ActionCardDisplay = card_display.instantiate()
					card_container.add_child(new_display,true)
					new_display.set_owner(get_tree().edited_scene_root)
					new_display.action_card = i.action_card
					new_display.load_display()

func clear_cards():
	if Engine.is_editor_hint():
		for i in creator_card_holder.get_children():
			if i is PlaysetCreatorCard:
				i.queue_free()
		for i in card_container.get_children():
			if i is ActionCardDisplay:
				i.queue_free()
#endregion
#region units
## adding a creator unit
func add_unit() -> PlaysetCreatorUnit:
	if Engine.is_editor_hint():
		var new_creator_unit : PlaysetCreatorUnit = creator_unit.instantiate()
		creator_unit_holder.add_child(new_creator_unit,true)
		new_creator_unit.set_owner(get_tree().edited_scene_root)
		return new_creator_unit
	return null

## for previewing functionality
func load_units():
	for i in creator_unit_holder.get_children():
		if i is PlaysetCreatorUnit:
			var unit_data : UnitData = i.unit_data
			var new_unit : Unit = load(unit_data.unit_uid).instantiate()
			new_unit.unit_data = unit_data
			unit_container.add_child(new_unit,true)
			new_unit.set_owner(get_tree().edited_scene_root)
	for i in unit_container.get_children().size():
		var child = unit_container.get_child(i)
		if child is Unit: #have to do this manually cause these aren't controls!
			child.position.y += 20
			child.position.x += 20 + i*40

func clear_units():
	if Engine.is_editor_hint():
		for i in unit_container.get_children():
			if i is Unit:
				i.queue_free()
		for i in creator_unit_holder.get_children():
			if i is PlaysetCreatorUnit:
				i.queue_free()
#endregion

func clear_dice():
	if Engine.is_editor_hint():
		pass #TODO: dis

## one way stop to clear town :P
func clear_all():
	if Engine.is_editor_hint():
		clear_cards()
		clear_units()
		clear_dice()

#region playset management
## cookin up the resource
func save_playset():
	if Engine.is_editor_hint():
		var new_ps : Playset = Playset.new()
		for i in creator_card_holder.get_children():
			if i is PlaysetCreatorCard:
				for j in range(i.quantity):
					new_ps.deck.append(i.action_card)
		for i in creator_unit_holder.get_children():
			if i is PlaysetCreatorUnit:
				new_ps.units.append(i.unit_data)
		var error : Error = ResourceSaver.save(new_ps,"res://data/playsets/"+String(resource_name)+".tres")
		if error != Error.OK:
			print(error)

## loading up the resource
func load_playset():
	if Engine.is_editor_hint():
		clear_all()
		var loaded_playset : Playset = load("res://data/playsets/"+String(resource_name)+".tres")
		var creator_deck : Array[ActionCard] = [] # reducing creator clutter
		for i in loaded_playset.deck: #cards
			if not i in creator_deck:
				creator_deck.append(i)
				var new_creator_card : PlaysetCreatorCard = add_card()
				new_creator_card.action_card = i
				new_creator_card.quantity = loaded_playset.deck.filter(func(ac): return ac == i).size()
				new_creator_card.name = i.name
		for i in loaded_playset.units: #units
			var new_creator_unit : PlaysetCreatorUnit = add_unit()
			new_creator_unit.unit_data = i
			new_creator_unit.name = i.name
		load_cards()
		load_units()
#endregion
