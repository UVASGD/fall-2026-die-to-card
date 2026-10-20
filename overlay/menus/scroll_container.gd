extends ScrollContainer

@onready var grid: GridContainer = $Grid
@onready var drag_layer: Control = $"../DragLayer"
@onready var dice_slots: Control = $"../DiceSlots"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in grid.get_children():
		child.drag_layer = drag_layer
		for slot in dice_slots.get_children():
			child.destinations.append(slot)
			child.global_position = slot.global_position
