class_name ActionCard
extends Resource

@export var name : String
@export var portrait : Texture
# the list of things the card can units accomplish
@export var actions : Dictionary[String,Dictionary] = {}
# the list of things the card can make the world accomplish
#NOTE: this currently is just a placeholder, things can be done with it in the future!
@export var events : Dictionary[String,Dictionary] = {}

#structure of an action in the actions array 
var action_template : Dictionary = {
	"value" = 0, # strength of action
	"intent" = Unit.INTENT_TYPE.NULL,
	"diceslot" = diceslot_template.duplicate_deep(),
	"text" = "", # description of action (to be put on display)
	"focus" = false # if the player is using this action (active/not)
}

#structure of a diceslot in the diceslot dictionary
var diceslot_template : Dictionary = {
	#TODO: restrictions here later
	"dice" = null #the actual dice, when attached by player
}

var event_template : Dictionary = {
	"text" = "", # description of action (to be put on display)
	"command" = "", # what to tell the world to do (check EventManager)
	"arguments" = "", # additional details for the eventmanager
	
}
