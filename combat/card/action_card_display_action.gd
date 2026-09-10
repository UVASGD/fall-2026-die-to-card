@tool #tool so it works in card creator
class_name ActionCardDisplayAction
extends HBoxContainer

### Base scene for an action line on an ActionCardDisplay
## This just makes it easier to "build" the card on the fly
# Yes I know the names are getting a little long...

var action_card : ActionCard = null
var action_name : String = ""
@onready var dice_button: TextureButton = $DiceButton
@onready var action_text_label: Label = $ActionText

func load_for_editor():
	if Engine.is_editor_hint():
		action_text_label = $ActionText
		dice_button = $DiceButton

func _on_dice_button_pressed() -> void:
	if CombatManager.selected_dice != null:
		#implement some other dice restriction stuff here later!
		action_card.actions.get(action_name).get("diceslot").set("dice",CombatManager.selected_dice)
		CombatManager.selected_dice = null #locking in the dice
		dice_button.disabled = true
