@tool
class_name CardCreatorEvent
extends Node

### Part of the Card Creator system, used to make "events" on cards
## Events make the world do things, not give units intents

# events are handled in EventManager, see there for info

@export var event_name : String = ""
@export var text : String = ""
@export var command : String = ""
@export var arguments : Array = []
