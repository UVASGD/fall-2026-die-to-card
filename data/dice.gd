class_name Die
extends Node


#
# dice goes to both troops and door
# type matters for card slots
#
#
#

@export var sides : int = 6
@export var weights : Array = []

var rolled_number : int
var used : bool = false
var luck : float = 0# -1 <= x <= 1
var color; # color goes into specified color slot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func roll():
	rolled_number = randi_range(1,sides)
	used = true
	return rolled_number

func lucky_roll(): #uses a calculus-esque approach to tilt probabilities towards one side or the other
	var max_tilt: float = 2/(sides**2 - sides) # maximum absolute tilt such that integral from 1 to sides of side probabilities = 100% and all positive
	var tilt = luck * max_tilt;
	var roll: float = randf()  # 0.0 <= roll < 1.0
	var cumulative: float = 0.0

	for x in range(1, sides + 1):
		var probability: float = tilt * (x - (sides + 1) / 2) + 1 / sides
		cumulative += probability

		if roll < cumulative:
			return x
	
	return sides #fallback

func remove():
	queue_free()
