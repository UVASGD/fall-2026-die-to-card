@tool #this is a tool script for card creator to function properly
class_name ActionCardDisplay
extends PanelContainer

### Handles the display of action cards in the hand, etc.
## should be provided an action card resource before brought into scene

#NOTE: please keep this node starting not visible, this is to help with any
#      potential visual glitches due to load_display doing its thing

signal card_moused()
signal card_clicked(ActionCardDisplay)

const VIEWPORT_DIAGONAL : float = 734.3

var move_tween : Tween
var action_card : ActionCard = null
var can_focus : bool = false # lock for when we don't want cards to be enlarged
var focus : bool = false # actual focus status
var can_select : bool = false #lock for when we don't want cards to be selected
@onready var name_label : Label = $AllVBox/NameMargin/Name
@onready var portrait_rect: TextureRect = $AllVBox/Portrait
@onready var action_display : PackedScene = preload("uid://dygcl7f4ktt3v")
@onready var action_box: VBoxContainer = $AllVBox/ActionMargin/ActionBox

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
		action.load_action(i,action_card.actions.get(i))
	visible = true

## Handling nice lookin movement of cards individually (and change on the fly!)
func move_target(new_target : Vector2, new_rotation : float, end_play : bool = false):
	if move_tween and move_tween.is_running():
		move_tween.kill()
	move_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	var distance : float = global_position.distance_to(new_target)
	var time : float = distance/VIEWPORT_DIAGONAL
	move_tween.parallel().tween_property(self,"position",new_target,time)
	move_tween.parallel().tween_property(self,"rotation",new_rotation,time)
	await move_tween.finished
	if end_play:
		queue_free()

## Clears out actions in the display
func clear_display():
	for i in action_box.get_children():
		if i is ActionCardDisplayAction:
			i.queue_free()

#the following two functions are there for focus, and other fun effects in the future
func _on_mouse_entered() -> void:
	if can_focus:
		focus = true
		z_index = 5
		card_moused.emit()

func _on_mouse_exited() -> void:
	z_index = 3
	if can_focus:
		focus = false
		card_moused.emit()

#for selecting cards (look at cardmanager)
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if can_select:
					card_clicked.emit(self)
