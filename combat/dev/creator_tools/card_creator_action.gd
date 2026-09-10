@tool
class_name CardCreatorAction
extends Node

# literally just remodel this for the display...5

@export var action_name : String = ""
@export_category("Action")
@export var value : int = 0
@export var intent : Unit.INTENT_TYPE = Unit.INTENT_TYPE.NULL
@export var text : String = ""
var focus : bool = false
@export_category("Diceslot")
# me gonna write this up when I get dice goin
var dice
