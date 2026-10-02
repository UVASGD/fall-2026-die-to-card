@tool #tool so it works in card creator
class_name ActionCardDisplayAction
extends HBoxContainer

### Base scene for an action line on an ActionCardDisplay
## This just makes it easier to "build" the card on the fly
# Yes I know the names are getting a little long...

var card_action : CardAction = null
var action_name : String = ""
@onready var dice_button: TextureButton = $DiceButton
@onready var action_text_label: Label = $ActionText

func load_for_editor():
	if Engine.is_editor_hint():
		action_text_label = $ActionText
		dice_button = $DiceButton

##call this when loading this scene into a display
func load_action(new_action_name : String, new_card_action : CardAction):
	card_action = new_card_action
	action_name = new_action_name
	action_text_label.text = card_action.text
	_load_dice_button()

#put more in here when it's time to do all that
##Loading up dice slot functionality in the action
func _load_dice_button():
	if not card_action.diceslot.is_empty():
		dice_button.visible = true
