extends Resource
class_name CardAction

###Confusing, I know, but it's the action for ActionCard

enum ACTION_TYPE {
	INTENT,
	EVENT
}

@export var action_type : ACTION_TYPE = ACTION_TYPE.INTENT
@export var text : String = "" #description of action (to be put on display)
@export var args : Array[String] = [] #additonal intent/event modifications (as necessary)
##action values, leave null if event
@export var value : int = 0 #strength of action
@export var intent_type : Unit.INTENT_TYPE = Unit.INTENT_TYPE.NULL
@export var diceslot : Dictionary = {} #not necessary for autocards! make it null!
var focus : bool = false #if the player is using this action (active/not)
##event values, leave null if action
@export var command : String = ""
