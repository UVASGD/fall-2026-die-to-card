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

### DOCUMENTATION FOR ARGS FOR INTENTS:
##
## target is who's getting impacted;
## valid options are: "self","ally","enemy","all"
##
## area is always based on the location of the current unit, unless otherwise stated;
## valid options are: "cell","cross","row","column","square"
## note that for square, displacement should be pointing at the cell at the top left of the square
##
## area size is the size of the shape specified in area
## valid options are: any integers, or a vector2i (vector2i is only used for square!)
## use 1 to use default size (usually a radius of 1)
##
## displacement is the positioning of the area away from the tile the current unit is on
## valid options are: any vector2i (.x = horizontal change, .y = vertical change)
## use Vector2i.ZERO to set no displacement
##
##
## HEAL: [target,area,area_size,displacement]
##
## MOVE: [] this needs no arguments; just use value!
##
## ATTACK: [target,area,area_size,displacement]; generally, target should only be all or enemy here
##
## DEFEND: [] this needs no arguments; just use value!
