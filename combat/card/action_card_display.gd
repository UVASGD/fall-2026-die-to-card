@tool #this is a tool script for card creator to function properly
class_name ActionCardDisplay
extends PanelContainer

### Handles the display of action cards in the hand, etc.
## should be provided an action card resource before brought into scene

#NOTE: please keep this node starting not visible, this is to help with any
#      potential visual glitches due to load_display doing its thing

var move_tween : Tween
var action_card : ActionCard = null
@onready var name_label : Label = $VBox/Name
@onready var portrait_rect: TextureRect = $VBox/Portrait
@onready var action_display : PackedScene = preload("uid://dygcl7f4ktt3v")
@onready var event_display : PackedScene = preload("uid://b7tl05xrsdl2l")
@onready var action_box: VBoxContainer = $VBox/ActionMargin/ActionBox

# WARNING: must supply an action card to the display before it can do anything!

# see ActionCard for structure of actions and diceslots and events
## call this AFTER bringing it into the scene to "build" the card
func load_display():
	clear_display()
	name_label.text = action_card.name
	portrait_rect.texture = action_card.portrait
	for i in action_card.actions.keys():
		var action : ActionCardDisplayAction = action_display.instantiate()
		action_box.add_child(action)
		if Engine.is_editor_hint():
			action.load_for_editor()
		action.action_card = action_card
		action.action_name = i
		action.action_text_label.text = action_card.actions.get(i).get("text")
		#TODO: dice stuff here later I believe
	for i in action_card.events.keys():
		var event : ActionCardDisplayEvent = event_display.instantiate()
		action_box.add_child(event)
		if Engine.is_editor_hint():
			event.load_for_editor()
		event.action_card = action_card
		event.event_name = i
		event.event_text_label.text = action_card.events.get(i).get("text")
	visible = true

## Handling nice lookin movement of cards individually (and change on the fly!)
func move_target(new_target : Vector2, new_rotation : float, end_play : bool = false):
	if move_tween and move_tween.is_running():
		move_tween.kill()
	move_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	move_tween.parallel().tween_property(self,"position",new_target,1.0)
	move_tween.parallel().tween_property(self,"rotation",new_rotation,1.0)
	await move_tween.finished
	if end_play:
		queue_free()

## Clears out actions in the display
func clear_display():
	for i in action_box.get_children():
		if i is ActionCardDisplayAction or i is ActionCardDisplayEvent:
			i.queue_free()
