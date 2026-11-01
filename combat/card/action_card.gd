class_name ActionCard
extends Resource

@export var name : String
@export var portrait : Texture
@export var card_class : Unit.UNIT_CLASS = Unit.UNIT_CLASS.NONE
# the list of things the card can units accomplish
@export var actions : Dictionary[String,CardAction] = {}
