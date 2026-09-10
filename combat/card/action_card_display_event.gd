@tool #tool so it works in card creator
class_name ActionCardDisplayEvent
extends HBoxContainer

### Base scene for an event line on an ActionCardDisplay
## This just makes it easier to "build" the card on the fly
# Yes I know the names are getting a little long...

var action_card : ActionCard = null
var event_name : String = ""
@onready var event_text_label: Label = $ActionText

func load_for_editor():
	if Engine.is_editor_hint():
		event_text_label = $EventText
